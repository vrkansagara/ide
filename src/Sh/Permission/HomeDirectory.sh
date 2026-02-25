#!/usr/bin/env bash
# =============================================================================
# HomeDirectory.sh — Enterprise-grade home directory permission hardening
# =============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
#
# Permission policy (Option B — Linux-safe defaults + golden-run .sh):
#
#   Directories                 : 0755   (world-readable dirs)
#   Regular files   (non-.sh)   : 0644   (world-readable files)
#   Executables     (non-.sh)   : 0755   (user-exec bit preserved)
#   Shell scripts   (*.sh)      : 0500   ← GOLDEN-RUN (owner r-x ONLY)
#   ~/.ssh  directory           : 0700
#   ~/.ssh  private keys        : 0600
#   ~/.ssh  public keys         : 0644
#   ~/.ssh  config/known_hosts  : 0600
#   ~/.aws  directory + subdirs : 0700 / files 0600
#   ~/.gnupg directory          : 0700 / files 0600
#   Sensitive dot-files         : 0600
#   User-local tmp (~/.tmp)     : 0700
#
# Golden-run rule for *.sh files:
#   Every .sh file found under HOME is forced to 0500 (r-x------):
#     - chmod +x  (owner can execute)
#     - owner-readable  (owner can read)
#     - NOT writable by anyone during normal operation
#     - group bits cleared (---) — group cannot read/write/execute
#     - other bits cleared (---) — others cannot read/write/execute
# =============================================================================
set -o errexit
set -o pipefail
set -o nounset

# ---------------------------------------------------------------------------
# Version / identity
# ---------------------------------------------------------------------------
readonly VERSION="2.0.0"
readonly PROGNAME="${0##*/}"
SCRIPT_TS="$(date '+%Y%m%dT%H%M%S' 2>/dev/null || echo 'unknown')"
readonly SCRIPT_TS

# ---------------------------------------------------------------------------
# Permission policy (immutable after declaration)
# ---------------------------------------------------------------------------
readonly DIR_PERMS="0755"          # directories
readonly FILE_PERMS="0644"         # regular non-.sh files
readonly EXEC_PERMS="0755"         # non-.sh files that already have user-exec bit
readonly SH_FILE_PERMS="0500"      # *.sh — golden-run: owner r-x ONLY
readonly SSH_DIR_PERMS="0700"
readonly SSH_PRIVATE_PERMS="0600"
readonly SSH_PUBLIC_PERMS="0644"
readonly TMP_PERMS="0700"

# ---------------------------------------------------------------------------
# Mutable runtime state
# ---------------------------------------------------------------------------
VERBOSE=0
DRY_RUN=0
ASSUME_YES=0
HOME_DIR="${HOME:-/root}"
USER_NAME="${USER:-$(id -un)}"
OS_NAME="$(uname -s 2>/dev/null || echo Unknown)"
SUDO_CMD=""

# Determine writable locations for lock + log based on privilege level
if [ "$(id -u)" -eq 0 ]; then
    LOCKFILE="/var/lock/${PROGNAME}.lock"
    LOGFILE="/var/log/${PROGNAME}.log"
else
    LOCKFILE="${TMPDIR:-/tmp}/${PROGNAME}.${USER_NAME}.lock"
    LOGFILE="${HOME_DIR}/.local/log/${PROGNAME}.log"
fi

# ---------------------------------------------------------------------------
# Colours — only when stdout is a TTY
# ---------------------------------------------------------------------------
_init_colors() {
    if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
        C_RESET="$(tput sgr0   2>/dev/null || printf '')"
        C_GREEN="$(tput setaf 2 2>/dev/null || printf '')"
        C_YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
        C_RED="$(tput setaf 1   2>/dev/null || printf '')"
        C_CYAN="$(tput setaf 6  2>/dev/null || printf '')"
        C_BOLD="$(tput bold     2>/dev/null || printf '')"
    else
        C_RESET=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''; C_BOLD=''
    fi
}
_init_colors

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------
_ts()     { date '+%Y-%m-%dT%H:%M:%S%z' 2>/dev/null || date; }

_log_file() {
    local level="$1"; shift
    local log_dir
    log_dir="$(dirname "$LOGFILE")"
    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir" 2>/dev/null || return 0
    fi
    printf '[%s] [%s] %s\n' "$(_ts)" "$level" "$*" >>"$LOGFILE" 2>/dev/null || true
}

# log() — debug trace, only visible with -v/--verbose
log()     { [ "$VERBOSE" -ne 0 ] && printf '[DEBUG] %s\n' "$*" || true; _log_file DEBUG "$*"; }
info()    { printf '%b[INFO]  %s%b\n'  "$C_GREEN"  "$*" "$C_RESET"; _log_file INFO  "$*"; }
warn()    { printf '%b[WARN]  %s%b\n'  "$C_YELLOW" "$*" "$C_RESET"; _log_file WARN  "$*"; }
fatal()   { printf '%b[FATAL] %s%b\n'  "$C_RED"    "$*" "$C_RESET" >&2; _log_file FATAL "$*"; exit 1; }
ok()      { printf '%b[OK]    %s%b\n'  "$C_GREEN"  "$*" "$C_RESET"; _log_file OK    "$*"; }
section() {
    printf '\n%b=== %s ===%b\n' "${C_BOLD}${C_CYAN}" "$*" "$C_RESET"
    _log_file STEP "=== $* ==="
}

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
${C_BOLD}${PROGNAME}${C_RESET} v${VERSION} — Enterprise home directory permission hardening

${C_BOLD}USAGE${C_RESET}
  $PROGNAME [OPTIONS]

${C_BOLD}DESCRIPTION${C_RESET}
  Applies ownership and permission hardening to \$HOME using Option B
  (Linux-safe defaults) with strict golden-run enforcement for *.sh files.

  Permission policy:
    Directories                    $DIR_PERMS   (world-readable)
    Regular files  (non-.sh)       $FILE_PERMS   (world-readable)
    Executables    (non-.sh)       $EXEC_PERMS   (world-executable, user-exec preserved)
    Shell scripts  (*.sh)          $SH_FILE_PERMS   GOLDEN-RUN — owner r-x only
    .ssh directory                 $SSH_DIR_PERMS
    .ssh private keys (id_*)       $SSH_PRIVATE_PERMS
    .ssh public keys  (*.pub)      $SSH_PUBLIC_PERMS
    .aws / .gnupg dirs + files     0700 / 0600
    Sensitive dot-files            0600
    User-local tmp  (~/.tmp)       $TMP_PERMS

  GOLDEN-RUN (*.sh → $SH_FILE_PERMS):
    Every shell script found under HOME receives chmod +x, and its
    permissions are locked to r-x------ (owner only). No write bit,
    no group access, no other access — prevents accidental tampering.

${C_BOLD}OPTIONS${C_RESET}
  -v, --verbose   Verbose / enable shell trace (set -x)
  --dry-run       Print actions without applying them
  --yes           Assume yes; skip interactive prompts
  --version       Print version and exit
  -h, --help      Show this help and exit

${C_BOLD}FILES${C_RESET}
  Log  : $LOGFILE
  Lock : $LOCKFILE

EOF
}

# ---------------------------------------------------------------------------
# Lock management
# ---------------------------------------------------------------------------
acquire_lock() {
    if [ -f "$LOCKFILE" ]; then
        local pid
        pid="$(cut -d: -f1 <"$LOCKFILE" 2>/dev/null || echo '')"
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            fatal "Another instance (PID $pid) is already running. Exiting."
        fi
        warn "Stale lockfile found; removing."
        rm -f "$LOCKFILE" || true
    fi
    printf '%s:%s\n' "$$" "$(date +%s 2>/dev/null || echo 0)" >"$LOCKFILE" 2>/dev/null \
        || warn "Could not create lockfile '$LOCKFILE'; proceeding without lock."
    trap '_on_exit' EXIT INT TERM HUP
}

_on_exit() {
    rm -f "$LOCKFILE" 2>/dev/null || true
    log "Cleanup: lockfile removed."
}

# ---------------------------------------------------------------------------
# Interactive confirmation
# ---------------------------------------------------------------------------
confirm() {
    [ "$ASSUME_YES" -ne 0 ] && return 0
    [ -t 0 ] || fatal "Interactive confirmation required but stdin is not a TTY. Use --yes."
    printf '%b%s%b [y/N]: ' "$C_YELLOW" "$*" "$C_RESET"
    local ans
    IFS= read -r ans
    case "$ans" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# Sudo wrapper — no eval, ever
# ---------------------------------------------------------------------------
_run() {
    # Prepends SUDO_CMD if set; otherwise executes directly.
    if [ -n "$SUDO_CMD" ]; then
        "$SUDO_CMD" "$@"
    else
        "$@"
    fi
}

# ---------------------------------------------------------------------------
# Core permission helpers (dry-run aware, no eval)
# ---------------------------------------------------------------------------

# Direct chmod: _chmod PERMS [options] FILE...
_chmod() {
    if [ "$DRY_RUN" -ne 0 ]; then
        log "[DRY-RUN] chmod $*"; return 0
    fi
    log "[RUN] chmod $*"
    _run chmod "$@" || true
}

# Direct chown: _chown [options] OWNER FILE...
_chown() {
    if [ "$DRY_RUN" -ne 0 ]; then
        log "[DRY-RUN] chown $*"; return 0
    fi
    log "[RUN] chown $*"
    _run chown "$@" || true
}

# mkdir -p wrapper
_mkdir_p() {
    if [ "$DRY_RUN" -ne 0 ]; then
        log "[DRY-RUN] mkdir -p $*"; return 0
    fi
    log "[RUN] mkdir -p $*"
    _run mkdir -p "$@" || true
}

# find-based chmod: _find_chmod BASE_DIR PERMS [find predicates...]
# Uses streaming find|xargs for memory efficiency on large trees.
_find_chmod() {
    local base_dir="$1"
    local perms="$2"
    shift 2
    # "$@" holds additional find predicates (e.g. -type f -name "*.sh")
    if [ "$DRY_RUN" -ne 0 ]; then
        log "[DRY-RUN] Would chmod $perms: find $base_dir -xdev $*"
        _run find "$base_dir" -xdev "$@" -print 2>/dev/null | head -20 || true
        return 0
    fi
    log "[RUN] chmod $perms (find $base_dir -xdev $*)"
    _run find "$base_dir" -xdev "$@" -print0 2>/dev/null \
        | _run xargs -0 -r chmod "$perms" || true
}

# find-based chown: _find_chown BASE_DIR OWNER [find predicates...]
_find_chown() {
    local base_dir="$1"
    local owner="$2"
    shift 2
    if [ "$DRY_RUN" -ne 0 ]; then
        log "[DRY-RUN] Would chown $owner: find $base_dir -xdev $*"; return 0
    fi
    log "[RUN] chown $owner (find $base_dir -xdev $*)"
    _run find "$base_dir" -xdev "$@" -print0 2>/dev/null \
        | _run xargs -0 -r chown -h "$owner" || true
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose)
                VERBOSE=1
                set -x
                shift ;;
            --dry-run)
                DRY_RUN=1
                shift ;;
            --yes)
                ASSUME_YES=1
                shift ;;
            --version)
                printf '%s v%s\n' "$PROGNAME" "$VERSION"
                exit 0 ;;
            -h|--help)
                usage
                exit 0 ;;
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
    # Always print help/usage header (original behaviour preserved)
    usage

    parse_args "$@"

    # ---- Privilege detection ----
    if [ "$(id -u)" -ne 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
            SUDO_CMD="sudo"
            info "Non-root session — sudo will be used for privileged operations."
        else
            warn "Non-root and sudo not found; some operations may fail silently."
        fi
    fi

    # ---- Sanity checks ----
    [ -d "$HOME_DIR" ] || fatal "HOME directory '$HOME_DIR' does not exist."

    if [ "$USER_NAME" = "root" ] && [ "$ASSUME_YES" -ne 1 ]; then
        warn "You are about to harden root's home directory."
        confirm "Continue modifying root's home?" || { ok "Aborted by user."; exit 0; }
    fi

    acquire_lock

    # ---- Audit header ----
    _log_file AUDIT "====== Run start ======"
    _log_file AUDIT "Script    : $0"
    _log_file AUDIT "Version   : $VERSION"
    _log_file AUDIT "UID/User  : $(id -u) / $USER_NAME"
    _log_file AUDIT "PID       : $$"
    _log_file AUDIT "HOME      : $HOME_DIR"
    _log_file AUDIT "OS        : $OS_NAME"
    _log_file AUDIT "Timestamp : $SCRIPT_TS"
    _log_file AUDIT "DRY_RUN   : $DRY_RUN"

    info "User   : $USER_NAME"
    info "HOME   : $HOME_DIR"
    info "OS     : $OS_NAME"
    info "Mode   : $([ "$DRY_RUN" -ne 0 ] && echo 'DRY-RUN (no changes)' || echo 'LIVE')"
    info "Log    : $LOGFILE"

    # =========================================================================
    section "Step 1 — Ownership normalisation"
    # =========================================================================
    info "Correcting ownership for objects not owned by $USER_NAME."
    _find_chown "$HOME_DIR" "${USER_NAME}:${USER_NAME}" -not -user "$USER_NAME"

    # =========================================================================
    section "Step 2 — Directory permissions ($DIR_PERMS)"
    # =========================================================================
    info "Setting all directories to $DIR_PERMS."
    _find_chmod "$HOME_DIR" "$DIR_PERMS" -type d

    # =========================================================================
    section "Step 3 — Base file permissions (non-.sh files)"
    # =========================================================================
    # IMPORTANT: Executable preservation is done FIRST (before mass reset),
    # so that files with user-exec bit can be identified from their current state.
    # Only then are remaining non-executables reset to FILE_PERMS.

    info "Preserving user-executable non-.sh files at $EXEC_PERMS."
    _find_chmod "$HOME_DIR" "$EXEC_PERMS" -type f ! -name "*.sh" -perm -u=x

    info "Setting non-executable non-.sh files to $FILE_PERMS."
    _find_chmod "$HOME_DIR" "$FILE_PERMS" -type f ! -name "*.sh" ! -perm -u=x

    # =========================================================================
    section "Step 4 — Shell script golden-run enforcement (*.sh → $SH_FILE_PERMS)"
    # =========================================================================
    info "GOLDEN-RUN: every *.sh file in $HOME_DIR → $SH_FILE_PERMS"
    info "  owner=r-x   group=---   other=---"
    info "  chmod +x enforced; no write bit; no group/other access."
    _find_chmod "$HOME_DIR" "$SH_FILE_PERMS" -type f -name "*.sh"

    if [ "$DRY_RUN" -eq 0 ]; then
        local sh_count
        sh_count="$(_run find "$HOME_DIR" -xdev -type f -name "*.sh" 2>/dev/null \
            | wc -l | tr -d ' ')"
        ok "Golden-run ($SH_FILE_PERMS) applied to $sh_count .sh file(s)."
    fi

    # =========================================================================
    section "Step 5 — SSH directory hardening"
    # =========================================================================
    local ssh_dir="${HOME_DIR}/.ssh"
    if [ -d "$ssh_dir" ]; then
        info "Hardening $ssh_dir"
        _chown -R "${USER_NAME}:${USER_NAME}" "$ssh_dir"
        _chmod "$SSH_DIR_PERMS" "$ssh_dir"

        # Private keys: id_* (excluding *.pub), scoped to .ssh root only
        if [ "$DRY_RUN" -ne 0 ]; then
            log "[DRY-RUN] Would chmod $SSH_PRIVATE_PERMS SSH private keys in $ssh_dir"
        else
            _run find "$ssh_dir" -maxdepth 1 -type f \
                -name 'id_*' ! -name '*.pub' -print0 2>/dev/null \
                | _run xargs -0 -r chmod "$SSH_PRIVATE_PERMS" || true
        fi

        # Public keys
        if [ "$DRY_RUN" -ne 0 ]; then
            log "[DRY-RUN] Would chmod $SSH_PUBLIC_PERMS SSH public keys in $ssh_dir"
        else
            _run find "$ssh_dir" -maxdepth 1 -type f \
                -name '*.pub' -print0 2>/dev/null \
                | _run xargs -0 -r chmod "$SSH_PUBLIC_PERMS" || true
        fi

        # Other sensitive SSH files
        for f in "${ssh_dir}/authorized_keys" "${ssh_dir}/known_hosts" \
                 "${ssh_dir}/config" "${ssh_dir}/environment"; do
            [ -f "$f" ] && _chmod "0600" "$f"
        done
        ok "SSH directory hardened."
    else
        warn "No $ssh_dir found; skipping SSH hardening."
    fi

    # =========================================================================
    section "Step 6 — User-local tmp ($TMP_PERMS)"
    # =========================================================================
    local user_tmp="${HOME_DIR}/.tmp"
    info "Ensuring $user_tmp with permissions $TMP_PERMS."
    _mkdir_p "$user_tmp"
    _chown "${USER_NAME}:${USER_NAME}" "$user_tmp"
    _chmod "$TMP_PERMS" "$user_tmp"

    # =========================================================================
    section "Step 7 — System /tmp sticky bit verification"
    # =========================================================================
    if [ -d /tmp ]; then
        info "Verifying /tmp has sticky bit (1777)."
        if [ "$DRY_RUN" -ne 0 ]; then
            log "[DRY-RUN] Would ensure /tmp is 1777."
        else
            _run chmod 1777 /tmp || warn "/tmp sticky bit could not be set."
        fi
    fi

    # =========================================================================
    section "Step 8 — Sensitive file hardening (0600)"
    # =========================================================================
    info "Restricting known sensitive dot-files to owner-read-only (0600)."

    # Explicit paths (not wildcard find — avoids over-broad basename matching)
    local sensitive_files
    sensitive_files=(
        "${HOME_DIR}/.env"
        "${HOME_DIR}/.secrets"
        "${HOME_DIR}/.mysql_history"
        "${HOME_DIR}/.psql_history"
        "${HOME_DIR}/.bash_history"
        "${HOME_DIR}/.zsh_history"
        "${HOME_DIR}/.git-credentials"
        "${HOME_DIR}/.netrc"
        "${HOME_DIR}/.pgpass"
        "${HOME_DIR}/.npmrc"
        "${HOME_DIR}/.pypirc"
        "${HOME_DIR}/.docker/config.json"
    )

    local f
    for f in "${sensitive_files[@]}"; do
        [ -f "$f" ] && { _chmod "0600" "$f"; log "Hardened: $f"; }
    done

    # .env.* wildcard variants — shallow scan (maxdepth 2 to catch .env.production etc.)
    if [ "$DRY_RUN" -ne 0 ]; then
        log "[DRY-RUN] Would chmod 0600 any .env.* files (up to depth 2)."
    else
        while IFS= read -r -d '' env_file; do
            _run chmod "0600" "$env_file" || true
            log "Hardened .env variant: $env_file"
        done < <(_run find "$HOME_DIR" -maxdepth 2 -type f -name ".env.*" -print0 2>/dev/null || true)
    fi

    # =========================================================================
    section "Step 9 — AWS credentials hardening"
    # =========================================================================
    local aws_dir="${HOME_DIR}/.aws"
    if [ -d "$aws_dir" ]; then
        info "Securing $aws_dir"
        _chown -R "${USER_NAME}:${USER_NAME}" "$aws_dir"
        # Set the .aws directory itself
        _chmod "0700" "$aws_dir"
        # All sub-directories
        if [ "$DRY_RUN" -ne 0 ]; then
            log "[DRY-RUN] Would chmod 0700 all dirs in $aws_dir."
            log "[DRY-RUN] Would chmod 0600 all files in $aws_dir."
        else
            _run find "$aws_dir" -mindepth 1 -type d -print0 2>/dev/null \
                | _run xargs -0 -r chmod "0700" || true
            _run find "$aws_dir" -type f -print0 2>/dev/null \
                | _run xargs -0 -r chmod "0600" || true
        fi
        ok "AWS config secured."
    else
        log "$aws_dir not found; skipping."
    fi

    # =========================================================================
    section "Step 10 — GPG directory hardening"
    # =========================================================================
    local gpg_dir="${HOME_DIR}/.gnupg"
    if [ -d "$gpg_dir" ]; then
        info "Securing $gpg_dir"
        _chown -R "${USER_NAME}:${USER_NAME}" "$gpg_dir"
        _chmod "0700" "$gpg_dir"
        if [ "$DRY_RUN" -ne 0 ]; then
            log "[DRY-RUN] Would chmod 0600 all files in $gpg_dir."
        else
            _run find "$gpg_dir" -type f -print0 2>/dev/null \
                | _run xargs -0 -r chmod "0600" || true
        fi
        ok "GPG directory secured."
    else
        log "$gpg_dir not found; skipping."
    fi

    # =========================================================================
    section "Step 11 — SELinux context restoration"
    # =========================================================================
    if command -v restorecon >/dev/null 2>&1; then
        info "Restoring SELinux file contexts for $HOME_DIR."
        if [ "$DRY_RUN" -ne 0 ]; then
            log "[DRY-RUN] Would run: restorecon -Rv $HOME_DIR"
        else
            _run restorecon -Rv "$HOME_DIR" 2>/dev/null \
                || warn "restorecon reported errors; check SELinux policy."
        fi
    else
        log "restorecon not available; skipping SELinux step."
    fi

    # =========================================================================
    section "Summary"
    # =========================================================================
    if [ "$DRY_RUN" -ne 0 ]; then
        warn "DRY-RUN complete — no changes were made to the filesystem."
    else
        info "Top-level listing of $HOME_DIR:"
        ls -la "$HOME_DIR" 2>/dev/null | head -40 || true
        printf '\n'
        ok "========================================================"
        ok " HOME DIRECTORY HARDENING COMPLETE"
        ok " Target  : $HOME_DIR"
        ok " Policy  : Option B + golden-run (*.sh -> $SH_FILE_PERMS)"
        ok " Log     : $LOGFILE"
        ok "========================================================"
    fi

    _log_file AUDIT "====== Run end (PID=$$, ts=$(date '+%Y%m%dT%H%M%S' 2>/dev/null)) ======"
}

main "$@"
