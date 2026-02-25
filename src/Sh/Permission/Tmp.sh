#!/usr/bin/env bash
# =============================================================================
# Tmp.sh — Enterprise-grade /tmp permission hardening
# =============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
#
# Permission policy (Linux /tmp standard):
#   /tmp                : 1777  (sticky + world-writable — required by POSIX)
#   /tmp/.*-unix dirs   : 1777  (socket dirs, e.g. .X11-unix, .ICE-unix)
#
# Security note:
#   This script does NOT remove go-rwx from arbitrary /tmp content.
#   Files in /tmp are owned by individual users; blanket permission removal
#   would break running processes (X11, DBus, systemd, etc.).
#   Only /tmp itself and known socket directories are touched.
# =============================================================================
set -o errexit
set -o pipefail
set -o nounset

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
readonly VERSION="2.0.0"
readonly PROGNAME="${0##*/}"

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
VERBOSE=0
DRY_RUN=0
ASSUME_YES=0
SUDO_CMD=""

# Socket directory patterns managed by this script
readonly SOCKET_DIR_PATTERN=".*-unix"

# ---------------------------------------------------------------------------
# Colours
# ---------------------------------------------------------------------------
_init_colors() {
    if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
        C_RESET="$(tput sgr0   2>/dev/null || printf '')";  C_GREEN="$(tput setaf 2 2>/dev/null || printf '')"
        C_YELLOW="$(tput setaf 3 2>/dev/null || printf '')"; C_RED="$(tput setaf 1 2>/dev/null || printf '')"
        C_CYAN="$(tput setaf 6 2>/dev/null || printf '')";   C_BOLD="$(tput bold 2>/dev/null || printf '')"
    else
        C_RESET=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''; C_BOLD=''
    fi
}
_init_colors

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
info()    { printf '%b[INFO]  %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
warn()    { printf '%b[WARN]  %s%b\n' "$C_YELLOW" "$*" "$C_RESET"; }
fatal()   { printf '%b[FATAL] %s%b\n' "$C_RED"    "$*" "$C_RESET" >&2; exit 1; }
ok()      { printf '%b[OK]    %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
log()     { [ "$VERBOSE" -ne 0 ] && printf '[DEBUG] %s\n' "$*" || true; }
section() { printf '\n%b=== %s ===%b\n' "${C_BOLD}${C_CYAN}" "$*" "$C_RESET"; }

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
${C_BOLD}${PROGNAME}${C_RESET} v${VERSION} — /tmp permission hardening (Linux standard)

${C_BOLD}USAGE${C_RESET}
  $PROGNAME [OPTIONS]

${C_BOLD}DESCRIPTION${C_RESET}
  Applies the correct Linux /tmp permission policy:

    /tmp                 1777  (sticky + world-writable, POSIX required)
    /tmp/.*-unix dirs    1777  (X11, ICE, DBus socket dirs)

  This script does NOT blanket-remove go-rwx from /tmp contents.
  Other users' files in /tmp are intentionally left untouched to avoid
  breaking running processes (X11, DBus, systemd-run, etc.).

${C_BOLD}OPTIONS${C_RESET}
  -v, --verbose   Verbose / enable shell trace
  --dry-run       Print actions without applying them
  --yes           Assume yes; skip interactive prompts
  --version       Print version and exit
  -h, --help      Show this help and exit

EOF
}

# ---------------------------------------------------------------------------
# Sudo wrapper — no eval
# ---------------------------------------------------------------------------
_run() {
    if [ -n "$SUDO_CMD" ]; then
        "$SUDO_CMD" "$@"
    else
        "$@"
    fi
}

# ---------------------------------------------------------------------------
# Dry-run-aware helpers
# ---------------------------------------------------------------------------
_chmod() {
    if [ "$DRY_RUN" -ne 0 ]; then log "[DRY-RUN] chmod $*"; return 0; fi
    log "[RUN] chmod $*"
    _run chmod "$@" || true
}

# ---------------------------------------------------------------------------
# Confirm prompt
# ---------------------------------------------------------------------------
confirm() {
    [ "$ASSUME_YES" -ne 0 ] && return 0
    [ -t 0 ] || fatal "Interactive confirmation required but stdin is not a TTY. Use --yes."
    printf '%b%s%b [y/N]: ' "$C_YELLOW" "$*" "$C_RESET"
    local ans
    IFS= read -r ans
    case "$ans" in [Yy]|[Yy][Ee][Ss]) return 0 ;; *) return 1 ;; esac
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose)
                VERBOSE=1; set -x; shift ;;
            --dry-run)
                DRY_RUN=1; shift ;;
            --yes)
                ASSUME_YES=1; shift ;;
            --version)
                printf '%s v%s\n' "$PROGNAME" "$VERSION"; exit 0 ;;
            -h|--help)
                usage; exit 0 ;;
            --)
                shift; break ;;
            -*)
                fatal "Unknown option: '$1'. Run with -h for help." ;;
            *)
                fatal "Unexpected argument: '$1'. Run with -h for help." ;;
        esac
    done
}

# ===========================================================================
# MAIN
# ===========================================================================
main() {
    usage
    parse_args "$@"

    # ---- Privilege detection ----
    if [ "$(id -u)" -ne 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
            SUDO_CMD="sudo"
            info "Non-root session — sudo will be used."
        else
            warn "Non-root and sudo not found; chmod on /tmp will likely fail."
        fi
    fi

    [ -d /tmp ] || fatal "/tmp does not exist on this system."

    info "Mode : $([ "$DRY_RUN" -ne 0 ] && echo 'DRY-RUN (no changes)' || echo 'LIVE')"

    # =========================================================================
    section "Step 1 — /tmp sticky bit (1777)"
    # =========================================================================
    info "Setting /tmp to 1777 (sticky + world-writable)."
    _chmod "1777" /tmp

    # Verify
    if [ "$DRY_RUN" -eq 0 ]; then
        local actual_perms
        actual_perms="$(stat -c '%a' /tmp 2>/dev/null || echo '?')"
        if [ "$actual_perms" = "1777" ]; then
            ok "/tmp is correctly set to 1777."
        else
            warn "/tmp has unexpected permissions: $actual_perms (expected 1777)."
        fi
    fi

    # =========================================================================
    section "Step 2 — Socket directories (.*-unix → 1777)"
    # =========================================================================
    info "Setting known socket directories in /tmp to 1777."
    info "  Pattern: /tmp/${SOCKET_DIR_PATTERN}"

    if [ "$DRY_RUN" -ne 0 ]; then
        log "[DRY-RUN] Would chmod 1777 on socket dirs matching: $SOCKET_DIR_PATTERN"
        _run find /tmp -mindepth 1 -maxdepth 1 \
            -type d -name "$SOCKET_DIR_PATTERN" -print 2>/dev/null || true
    else
        local count=0
        while IFS= read -r -d '' socket_dir; do
            _run chmod "1777" "$socket_dir" || true
            log "Set 1777 on: $socket_dir"
            count=$((count + 1))
        done < <(_run find /tmp -mindepth 1 -maxdepth 1 \
            -type d -name "$SOCKET_DIR_PATTERN" -print0 2>/dev/null || true)

        if [ "$count" -gt 0 ]; then
            ok "Applied 1777 to $count socket director(y/ies)."
        else
            info "No socket directories matching '$SOCKET_DIR_PATTERN' found in /tmp."
        fi
    fi

    # =========================================================================
    section "Summary"
    # =========================================================================
    if [ "$DRY_RUN" -ne 0 ]; then
        warn "DRY-RUN complete — no changes were made."
    else
        info "Current /tmp permissions:"
        ls -ld /tmp 2>/dev/null || true
        printf '\n'
        ok "========================================================"
        ok " /tmp PERMISSION HARDENING COMPLETE"
        ok " /tmp           : 1777 (sticky + world-writable)"
        ok " Socket dirs    : 1777 (.*-unix)"
        ok "========================================================"
    fi
}

main "$@"
