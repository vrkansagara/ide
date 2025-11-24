#!/usr/bin/env bash
# Reset and harden home directory permissions (regular Linux-safe mode)
# Maintainer :- vallabhdas kansagara <vrkansagara@gmail.com> — @vrkansagara
# Note       :- Keeps typical Linux-friendly permissions (Option B), hardens sensitive files.

# ------------------------
# Safety flags
# ------------------------
set -o errexit
set -o pipefail
set -o nounset

# ------------------------
# Defaults / configuration
# ------------------------
PROGNAME="${0##*/}"
VERBOSE=0
DRY_RUN=0
ASSUME_YES=0
LOCKFILE="/var/lock/${PROGNAME}.lock"
LOGFILE="/var/log/${PROGNAME}.log"
HOME_DIR="${HOME:-/root}"
USER_NAME="${USER:-$(id -un)}"
SUDO=""
OS_NAME="$(uname -s 2>/dev/null || echo Unknown)"

# Permission policy (Option B: normal Linux-safe perms)
DIR_PERMS="0755"       # directories
FILE_PERMS="0644"      # regular files
EXEC_PERMS="0755"      # user+group+other exec only when file already executable by user
SSH_DIR_PERMS="0700"
SSH_PRIVATE_PERMS="0600"
SSH_PUBLIC_PERMS="0644"
TMP_DIR="${HOME_DIR}/tmp"

# ------------------------
# Colors (if supported)
# ------------------------
if [ -t 1 ]; then
    # Use tput if available for portability; fall back to ANSI if not
    if command -v tput >/dev/null 2>&1; then
        COLOR_RESET="$(tput sgr0 2>/dev/null || echo '')"
        COLOR_GREEN="$(tput setaf 2 2>/dev/null || echo '')"
        COLOR_YELLOW="$(tput setaf 3 2>/dev/null || echo '')"
        COLOR_RED="$(tput setaf 1 2>/dev/null || echo '')"
    else
        COLOR_RESET=$'\e[0m'
        COLOR_GREEN=$'\e[32m'
        COLOR_YELLOW=$'\e[33m'
        COLOR_RED=$'\e[31m'
    fi
else
    COLOR_RESET=''
    COLOR_GREEN=''
    COLOR_YELLOW=''
    COLOR_RED=''
fi

log() {
    local ts
    ts="$(date --iso-8601=seconds 2>/dev/null || date)"
    if [ "$VERBOSE" -ne 0 ]; then
        printf '%s %s\n' "$ts" "$*" >&2
    else
        printf '%s %s\n' "$ts" "$*"
    fi
    if [ -w "$(dirname "$LOGFILE")" ] || [ -w "$LOGFILE" ] 2>/dev/null; then
        printf '%s %s\n' "$ts" "$*" >>"$LOGFILE" 2>/dev/null || true
    fi
}

ok()    { printf '%b%s%b\n' "$COLOR_GREEN" "$*" "$COLOR_RESET"; log "$*"; }
warn()  { printf '%b%s%b\n' "$COLOR_YELLOW" "$*" "$COLOR_RESET"; log "WARN: $*"; }
fatal() { printf '%b%s%b\n' "$COLOR_RED" "$*" "$COLOR_RESET" >&2; log "ERROR: $*"; exit 1; }

usage() {
    cat <<EOF

$PROGNAME - Harden user's home directory (Option B: Linux-safe defaults)

Description:
  - Applies sane ownership and permissions inside your HOME.
  - Directories -> $DIR_PERMS
  - Files -> $FILE_PERMS
  - Existing user-executables preserved (-> $EXEC_PERMS)
  - .ssh and common sensitive files hardened (private keys, .env, *history)
  - Safe defaults: dry-run, verbose, non-interactive mode.

Options:
  -v           Verbose / enable shell trace
  --dry-run    Show actions but do not perform them
  --yes        Assume yes; no interactive prompts
  -h, --help   Show this help and exit

Notes:
  - This script uses streaming find|xargs to be memory-efficient.
  - It will NOT make the entire home private (Option A) — it's the more lenient, compatible
    Option B. Sensitive files are restricted by name patterns.
  - A lockfile prevents concurrent runs.

EOF
}

acquire_lock() {
    if [ -f "$LOCKFILE" ]; then
        local pid
        pid="$(cut -d: -f1 < "$LOCKFILE" 2>/dev/null || true)"
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            fatal "Another instance (pid $pid) is running. Exiting."
        else
            warn "Stale lockfile found; removing."
            rm -f "$LOCKFILE" || true
        fi
    fi
    printf '%s:%s\n' "$$" "$(date +%s)" >"$LOCKFILE"
    trap 'rm -f "$LOCKFILE"; log "Lock released";' EXIT INT TERM
}

safe_run() {
    # DRY_RUN aware
    if [ "$DRY_RUN" -ne 0 ]; then
        log "[DRY-RUN] $*"
    else
        log "[RUN] $*"
        eval "$@"
    fi
}

confirm() {
    if [ "$ASSUME_YES" -ne 0 ]; then return 0; fi
    if [ ! -t 0 ]; then
        fatal "Interactive confirmation required but stdin not a TTY. Use --yes for non-interactive."
    fi
    printf "%s [y/N]: " "$*"
    read -r ans
    case "$ans" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

# ------------------------
# Parse args and print help on execution (as requested)
# ------------------------
# Print help immediately when script is invoked
usage

while [ $# -gt 0 ]; do
    case "$1" in
        -v)
            VERBOSE=1
            set -x
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --yes)
            ASSUME_YES=1
            shift
            ;;
        -h|--help)
            exit 0
            ;;
        *)
            fatal "Unknown option: $1"
            ;;
    esac
done

# ------------------------
# Privilege detection & sanity checks
# ------------------------
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        warn "Running without root; some operations may fail."
    fi
fi

if [ ! -d "$HOME_DIR" ]; then
    fatal "HOME directory '$HOME_DIR' does not exist."
fi

if [ "$USER_NAME" = "root" ] && [ "$ASSUME_YES" -ne 1 ]; then
    warn "Modifying root's home may be dangerous."
    if ! confirm "Proceed to modify root's home directory?"; then
        ok "Aborting per user input."
        exit 0
    fi
fi

acquire_lock

# ------------------------
# Start actions
# ------------------------
ok "Starting permission hardening for user: $USER_NAME, HOME: $HOME_DIR, Mode: Option B (Linux-safe)."

# 1) Change ownership only for files/directories not owned by the user (reduces churn)
ok "Adjusting ownership for files not owned by $USER_NAME (streaming)."
safe_run "$SUDO find \"$HOME_DIR\" -xdev -not -user \"$USER_NAME\" -print0 | $SUDO xargs -0 -r chown -h \"$USER_NAME\":\"$USER_NAME\" || true"

# 2) Apply directory permissions
ok "Applying directory permissions: $DIR_PERMS"
safe_run "$SUDO find \"$HOME_DIR\" -xdev -type d -print0 | $SUDO xargs -0 -r chmod $DIR_PERMS || true"

# 3) Apply default file permissions
ok "Applying default file permissions: $FILE_PERMS"
safe_run "$SUDO find \"$HOME_DIR\" -xdev -type f -print0 | $SUDO xargs -0 -r chmod $FILE_PERMS || true"

# 4) Preserve executables: for files with user-exec bit set, ensure exec perms
ok "Preserving executable bit for user executables (set to $EXEC_PERMS)."
# Find files that have the user-exec bit, set them to EXEC_PERMS
safe_run "$SUDO find \"$HOME_DIR\" -xdev -type f -perm -u=x -print0 | $SUDO xargs -0 -r chmod $EXEC_PERMS || true"

# Also ensure other non-executable files do NOT have o+x or g+x
ok "Removing group/other execute bits from non-executables to avoid accidental execution."
safe_run "$SUDO find \"$HOME_DIR\" -xdev -type f ! -perm -u=x -print0 | $SUDO xargs -0 -r chmod go-x || true"

# 5) Harden .ssh dir and keys
if [ -d "$HOME_DIR/.ssh" ]; then
    ok "Hardening SSH directory and keys."
    safe_run "$SUDO chown -R \"$USER_NAME\":\"$USER_NAME\" \"$HOME_DIR/.ssh\" || true"
    safe_run "$SUDO chmod $SSH_DIR_PERMS \"$HOME_DIR/.ssh\" || true"
    safe_run "$SUDO find \"$HOME_DIR/.ssh\" -maxdepth 1 -type f -name 'id_*' -a ! -name '*.pub' -print0 | $SUDO xargs -0 -r chmod $SSH_PRIVATE_PERMS || true"
    safe_run "$SUDO find \"$HOME_DIR/.ssh\" -maxdepth 1 -type f -name '*.pub' -print0 | $SUDO xargs -0 -r chmod $SSH_PUBLIC_PERMS || true"
else
    warn "No .ssh directory found; skipping SSH hardening."
fi

# 6) Create and secure user-local tmp
ok "Ensuring user-local tmp ($TMP_DIR) exists (0700)."
safe_run "$SUDO mkdir -p \"$TMP_DIR\" || true"
safe_run "$SUDO chown \"$USER_NAME\":\"$USER_NAME\" \"$TMP_DIR\" || true"
safe_run "$SUDO chmod 0700 \"$TMP_DIR\" || true"

# 7) Ensure system /tmp is sticky (1777) — do not make it world-writable without sticky bit
ok "Verifying system /tmp sticky perms (1777)."
if [ -d /tmp ]; then
    safe_run "$SUDO chmod 1777 /tmp || true"
fi

# 8) Harden common sensitive files (Option B specific)
# Files and patterns to harden to 600 / 700 as applicable
SENSITIVE_PATTERNS=(
    "$HOME_DIR/.env"
    "$HOME_DIR/.env.*"
    "$HOME_DIR/.secrets"
    "$HOME_DIR/.mysql_history"
    "$HOME_DIR/.psql_history"
    "$HOME_DIR/.bash_history"
    "$HOME_DIR/.zsh_history"
    "$HOME_DIR/.aws/credentials"
    "$HOME_DIR/.git-credentials"
    "$HOME_DIR/.netrc"
)

ok "Hardening sensitive files (making readable only by user where found)."
for pat in "${SENSITIVE_PATTERNS[@]}"; do
    # Use shell globbing safely with find
    safe_run "$SUDO find \"$HOME_DIR\" -xdev -type f -name \"$(basename "$pat")\" -print0 2>/dev/null | $SUDO xargs -0 -r chmod 0600 || true"
done

# Also secure entire ~/.aws directory if present
if [ -d "$HOME_DIR/.aws" ]; then
    ok "Securing ~/.aws"
    safe_run "$SUDO chown -R \"$USER_NAME\":\"$USER_NAME\" \"$HOME_DIR/.aws\" || true"
    safe_run "$SUDO find \"$HOME_DIR/.aws\" -type d -print0 | $SUDO xargs -0 -r chmod 0700 || true"
    safe_run "$SUDO find \"$HOME_DIR/.aws\" -type f -print0 | $SUDO xargs -0 -r chmod 0600 || true"
fi

# 9) Optionally restore SELinux contexts if applicable
if command -v restorecon >/dev/null 2>&1; then
    ok "Restoring SELinux file contexts for $HOME_DIR (if applicable)."
    safe_run "$SUDO restorecon -Rv \"$HOME_DIR\" || true"
fi

# 10) Final verification summary (limited output to stay low-memory friendly)
ok "Summary (top-level listing, up to 200 entries):"
if [ "$DRY_RUN" -ne 0 ]; then
    log "[DRY-RUN] Skipping final stat listing."
else
    safe_run "$SUDO ls -ld \"$HOME_DIR\"/* 2>/dev/null | head -n 200 || true"
fi

ok "Permission hardening completed successfully for $HOME_DIR"
exit 0
