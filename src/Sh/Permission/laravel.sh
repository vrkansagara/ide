#!/usr/bin/env bash
# =============================================================================
# laravel.sh — Enterprise-grade Laravel project permission hardening
# =============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
#
# Permission policy (Laravel standard):
#   Project root (dirs)              : owner:web-group ownership
#   storage/ + bootstrap/cache/      : ug+rwx  (web group writable)
#   artisan                          : 0750    (owner r-x, group r-x, no other)
#   All other files                  : ownership corrected only
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
TARGET_DIR="$(pwd)"
WEB_GROUP="www-data"
USER_NAME="${USER:-$(id -un)}"
SUDO_CMD=""

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
${C_BOLD}${PROGNAME}${C_RESET} v${VERSION} — Laravel project permission hardening

${C_BOLD}USAGE${C_RESET}
  $PROGNAME [OPTIONS] [TARGET_DIR]

${C_BOLD}DESCRIPTION${C_RESET}
  Applies standard Laravel ownership and permission policy to a project.
  Must be run from or pointed at the Laravel project root.

  Policy:
    Ownership                  : \$USER:$WEB_GROUP on all files/dirs
    storage/ + bootstrap/cache : ug+rwx (owner + web group writable)
    artisan                    : 0750 (owner rwx, group r-x, no other)

${C_BOLD}OPTIONS${C_RESET}
  -g, --group GROUP   Web server group (default: $WEB_GROUP)
  -v, --verbose       Verbose / enable shell trace
  --dry-run           Print actions without applying them
  --yes               Assume yes; skip interactive prompts
  --version           Print version and exit
  -h, --help          Show this help and exit

${C_BOLD}ARGUMENTS${C_RESET}
  TARGET_DIR          Path to the Laravel project root (default: current directory)

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

_chown() {
    if [ "$DRY_RUN" -ne 0 ]; then log "[DRY-RUN] chown $*"; return 0; fi
    log "[RUN] chown $*"
    _run chown "$@" || true
}

_chgrp() {
    if [ "$DRY_RUN" -ne 0 ]; then log "[DRY-RUN] chgrp $*"; return 0; fi
    log "[RUN] chgrp $*"
    _run chgrp "$@" || true
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
            -g|--group)
                [ $# -lt 2 ] && fatal "Missing argument for $1"
                WEB_GROUP="$2"; shift 2 ;;
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
                TARGET_DIR="$1"; shift ;;
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
            info "Non-root session — sudo will be used for privileged operations."
        else
            warn "Non-root and sudo not found; some operations may fail."
        fi
    fi

    # ---- Sanity checks ----
    TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" \
        || fatal "Target directory '$TARGET_DIR' does not exist or is not accessible."

    # Verify this looks like a Laravel project
    if [ ! -f "${TARGET_DIR}/artisan" ]; then
        warn "No 'artisan' file found in '$TARGET_DIR' — this may not be a Laravel project."
        confirm "Continue applying Laravel permissions to '$TARGET_DIR'?" \
            || { ok "Aborted by user."; exit 0; }
    fi

    # Verify web group exists
    if ! getent group "$WEB_GROUP" >/dev/null 2>&1; then
        warn "Web group '$WEB_GROUP' does not exist on this system."
        confirm "Continue anyway?" || { ok "Aborted by user."; exit 0; }
    fi

    info "Target  : $TARGET_DIR"
    info "User    : $USER_NAME"
    info "Group   : $WEB_GROUP"
    info "Mode    : $([ "$DRY_RUN" -ne 0 ] && echo 'DRY-RUN (no changes)' || echo 'LIVE')"

    # =========================================================================
    section "Step 1 — Ownership: $USER_NAME:$WEB_GROUP"
    # =========================================================================
    info "Setting ownership to $USER_NAME:$WEB_GROUP on entire project."
    _chown -R "${USER_NAME}:${WEB_GROUP}" "$TARGET_DIR"

    # =========================================================================
    section "Step 2 — Web-writable directories"
    # =========================================================================
    local writable_dirs=("storage" "bootstrap/cache")
    local d
    for d in "${writable_dirs[@]}"; do
        local full_path="${TARGET_DIR}/${d}"
        if [ -d "$full_path" ]; then
            info "Setting ug+rwx on $full_path"
            _chgrp -R "$WEB_GROUP" "$full_path"
            _chmod -R "ug+rwx" "$full_path"
        else
            warn "Directory not found (skipping): $full_path"
        fi
    done

    # =========================================================================
    section "Step 3 — artisan executable"
    # =========================================================================
    local artisan="${TARGET_DIR}/artisan"
    if [ -f "$artisan" ]; then
        info "Setting artisan to 0750 (owner rwx, group r-x, no other)."
        _chmod "0750" "$artisan"
    else
        warn "artisan not found; skipping."
    fi

    # =========================================================================
    section "Step 4 — Artisan cache clear (optional)"
    # =========================================================================
    if [ "$DRY_RUN" -ne 0 ]; then
        info "[DRY-RUN] Would run artisan cache clears."
    elif command -v php >/dev/null 2>&1 && [ -f "$artisan" ]; then
        info "Running artisan cache clears."
        php "$artisan" route:clear  && ok "route:clear done."  || warn "route:clear failed."
        php "$artisan" view:clear   && ok "view:clear done."   || warn "view:clear failed."
        php "$artisan" config:clear && ok "config:clear done." || warn "config:clear failed."
    else
        warn "PHP not found or artisan missing; skipping cache clears."
    fi

    # =========================================================================
    section "Summary"
    # =========================================================================
    if [ "$DRY_RUN" -ne 0 ]; then
        warn "DRY-RUN complete — no changes were made."
    else
        ok "======================================================"
        ok " LARAVEL PERMISSION HARDENING COMPLETE"
        ok " Target  : $TARGET_DIR"
        ok " Owner   : $USER_NAME:$WEB_GROUP"
        ok "======================================================"
    fi
}

main "$@"
