#!/usr/bin/env bash
# =============================================================================
# magento2.sh — Enterprise-grade Magento 2 project permission hardening
# =============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
#
# Permission policy (Magento 2 standard):
#   Project ownership            : $USER:$WEB_GROUP
#   Writable dirs (g+ws)         : var/ generated/ vendor/ pub/static/
#                                  pub/media/ app/etc/
#   Writable files (g+w)         : same tree
#   bin/magento                  : 0750   (owner rwx, group r-x, no other)
#   app/etc/env.php              : 0660   (owner rw, group rw, NO other)
#                                  (NOT o+rwx — that was a security hole)
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
${C_BOLD}${PROGNAME}${C_RESET} v${VERSION} — Magento 2 project permission hardening

${C_BOLD}USAGE${C_RESET}
  $PROGNAME [OPTIONS] [TARGET_DIR]

${C_BOLD}DESCRIPTION${C_RESET}
  Applies the standard Magento 2 ownership and permission policy to a project.
  Must be run from or pointed at the Magento 2 project root.

  Policy:
    Ownership                                : \$USER:$WEB_GROUP
    var/ generated/ vendor/ pub/ app/etc/    : g+w (files), g+ws (dirs)
    bin/magento                              : 0750 (owner rwx, group r-x)
    app/etc/env.php                          : 0660 (owner+group rw, no other)

  Security note: app/etc/env.php is set to 0660, NOT o+rwx. World-readable
  or world-writable config files expose database credentials.

${C_BOLD}OPTIONS${C_RESET}
  -g, --group GROUP   Web server group (default: $WEB_GROUP)
  -v, --verbose       Verbose / enable shell trace
  --dry-run           Print actions without applying them
  --yes               Assume yes; skip interactive prompts
  --version           Print version and exit
  -h, --help          Show this help and exit

${C_BOLD}ARGUMENTS${C_RESET}
  TARGET_DIR          Path to the Magento 2 project root (default: current directory)

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

_mkdir_p() {
    if [ "$DRY_RUN" -ne 0 ]; then log "[DRY-RUN] mkdir -p $*"; return 0; fi
    log "[RUN] mkdir -p $*"
    _run mkdir -p "$@" || true
}

_touch() {
    if [ "$DRY_RUN" -ne 0 ]; then log "[DRY-RUN] touch $*"; return 0; fi
    log "[RUN] touch $*"
    _run touch "$@" || true
}

# find-based chmod: _find_chmod BASE_DIR PERMS [find predicates...]
_find_chmod() {
    local base_dir="$1"
    local perms="$2"
    shift 2
    if [ "$DRY_RUN" -ne 0 ]; then
        log "[DRY-RUN] Would chmod $perms: find $base_dir $*"
        return 0
    fi
    log "[RUN] chmod $perms (find $base_dir $*)"
    _run find "$base_dir" "$@" -print0 2>/dev/null \
        | _run xargs -0 -r chmod "$perms" || true
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

    # Verify this looks like a Magento 2 project
    if [ ! -f "${TARGET_DIR}/bin/magento" ] && [ ! -f "${TARGET_DIR}/app/etc/di.xml" ]; then
        warn "No 'bin/magento' or 'app/etc/di.xml' found — this may not be a Magento 2 project."
        confirm "Continue applying Magento 2 permissions to '$TARGET_DIR'?" \
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
    section "Step 2 — Group-writable files and setgid directories"
    # =========================================================================
    # Directories that Magento's web process must write to
    local writable_roots=("var" "generated" "vendor" "pub/static" "pub/media" "app/etc")
    local d
    for d in "${writable_roots[@]}"; do
        local full_path="${TARGET_DIR}/${d}"
        if [ -d "$full_path" ]; then
            info "Applying g+w (files) and g+ws (dirs) on $full_path"
            _find_chmod "$full_path" "g+w"  -type f
            _find_chmod "$full_path" "g+ws" -type d
        else
            warn "Directory not found (skipping): $full_path"
        fi
    done

    # Also apply to app/code and lib if present
    local extra_roots=("app/code" "lib")
    for d in "${extra_roots[@]}"; do
        local full_path="${TARGET_DIR}/${d}"
        if [ -d "$full_path" ]; then
            info "Applying g+w (files) and g+ws (dirs) on $full_path"
            _find_chmod "$full_path" "g+w"  -type f
            _find_chmod "$full_path" "g+ws" -type d
        fi
    done

    # =========================================================================
    section "Step 3 — bin/magento executable"
    # =========================================================================
    local magento_bin="${TARGET_DIR}/bin/magento"
    if [ -f "$magento_bin" ]; then
        info "Setting bin/magento to 0750 (owner rwx, group r-x, no other)."
        _chmod "0750" "$magento_bin"
    else
        warn "bin/magento not found; skipping."
    fi

    # =========================================================================
    section "Step 4 — app/etc directory and env.php"
    # =========================================================================
    local etc_dir="${TARGET_DIR}/app/etc"

    # Ensure app/etc exists (created separately so ownership can be set properly)
    if [ ! -d "$etc_dir" ]; then
        info "Creating $etc_dir"
        _mkdir_p "$etc_dir"
        _chown "${USER_NAME}:${WEB_GROUP}" "$etc_dir"
        _chmod "0770" "$etc_dir"
    fi

    local env_php="${etc_dir}/env.php"
    if [ ! -f "$env_php" ]; then
        info "Creating empty $env_php"
        _touch "$env_php"
        _chown "${USER_NAME}:${WEB_GROUP}" "$env_php"
    fi

    # SECURITY: 0660 = owner rw, group rw, no other access.
    # env.php contains DB credentials — never make it world-readable or world-writable.
    info "Setting $env_php to 0660 (owner+group rw, no other access)."
    _chmod "0660" "$env_php"

    # =========================================================================
    section "Summary"
    # =========================================================================
    if [ "$DRY_RUN" -ne 0 ]; then
        warn "DRY-RUN complete — no changes were made."
    else
        ok "======================================================"
        ok " MAGENTO 2 PERMISSION HARDENING COMPLETE"
        ok " Target  : $TARGET_DIR"
        ok " Owner   : $USER_NAME:$WEB_GROUP"
        ok " env.php : 0660 (owner+group rw, no other)"
        ok "======================================================"
    fi
}

main "$@"
