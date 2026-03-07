#!/usr/bin/env bash
# ==============================================================================
# disk-analyzer.sh — System disk usage analyzer and space recovery advisor
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
#
# Description:
#   Identifies disk space hogs and safe cleanup targets across an entire Linux
#   system.  Must be run as root (many paths are inaccessible otherwise).
#   Covers: APT cache, old kernels, systemd journal, /tmp, core dumps, Docker,
#   old logs, snap revisions, user caches, orphaned packages, thumbnails, and
#   more.
#
# Usage:
#   sudo disk-analyzer.sh [OPTIONS]
#   sudo disk-analyzer.sh --menu          # interactive menu (default)
#   sudo disk-analyzer.sh --report        # analysis only, no cleanup prompts
#   sudo disk-analyzer.sh --clean-all     # clean everything (with confirm each)
#   sudo disk-analyzer.sh --auto-clean    # non-interactive full cleanup (CRON)

set -o errexit
set -o pipefail
set -o nounset

readonly SCRIPT_VERSION="2.0.0"
readonly PROGNAME="${0##*/}"
VERBOSE=0
DRY_RUN=0

# Minimum file age (days) for /tmp sweeps
TMP_AGE_DAYS=7

# Size threshold for "large file" scan (in MB)
LARGE_FILE_MB=100

# Maximum journal size to keep when trimming
JOURNAL_KEEP="200M"

# Log of every cleanup action taken this session
readonly SESSION_LOG="/tmp/disk-analyzer-$(date +%Y%m%d%H%M%S).log"

# Per-category savings tracking: each clean_* writes "bytes\tlabel" here
SAVINGS_FILE="$(mktemp /tmp/disk-savings-XXXX.tsv)"

# ─── Colors ──────────────────────────────────────────────────────────────────
_init_colors() {
    if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
        C_RESET="$(tput sgr0    2>/dev/null || printf '')"; C_GREEN="$(tput setaf 2  2>/dev/null || printf '')"
        C_YELLOW="$(tput setaf 3 2>/dev/null || printf '')"; C_RED="$(tput setaf 1   2>/dev/null || printf '')"
        C_CYAN="$(tput setaf 6  2>/dev/null || printf '')";  C_BOLD="$(tput bold     2>/dev/null || printf '')"
        C_MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"; C_WHITE="$(tput setaf 7 2>/dev/null || printf '')"
        C_DIM="$(tput dim 2>/dev/null || printf '')"
    else
        C_RESET=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''
        C_BOLD=''; C_MAGENTA=''; C_WHITE=''; C_DIM=''
    fi
}
_init_colors

info()    { printf '%b[INFO]  %s%b\n'  "$C_GREEN"              "$*" "$C_RESET"; }
warn()    { printf '%b[WARN]  %s%b\n'  "$C_YELLOW"             "$*" "$C_RESET"; }
fatal()   { printf '%b[FATAL] %s%b\n'  "$C_RED"                "$*" "$C_RESET" >&2; exit 1; }
ok()      { printf '%b[OK]    %s%b\n'  "$C_GREEN"              "$*" "$C_RESET"; }
log()     { [ "$VERBOSE" -ne 0 ] && printf '[DEBUG] %s\n' "$*" || true; }
section() { printf '\n%b=== %s ===%b\n' "${C_BOLD}${C_CYAN}"   "$*" "$C_RESET"; }
step()    { printf '%b  -> %s%b\n'     "$C_MAGENTA"            "$*" "$C_RESET"; }
skip()    { printf '%b[SKIP]  %s%b\n'  "$C_DIM"                "$*" "$C_RESET"; }
saved()   { printf '%b[FREED] %s%b\n'  "${C_BOLD}${C_GREEN}"   "$*" "$C_RESET"; }

on_error() {
    local code=$? line="${BASH_LINENO[0]}"
    warn "Unexpected failure at line ${line} (exit ${code})."
    exit "${code}"
}
trap on_error ERR
trap 'rm -f "${SAVINGS_FILE:-}"' EXIT

_session_log() {
    printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" >> "$SESSION_LOG"
}

# ─── Savings tracking ─────────────────────────────────────────────────────────

# Convert raw bytes to a human-readable string  e.g. 1234567890 → "1.1 GB"
_bytes_to_human() {
    awk -v b="${1:-0}" 'BEGIN {
        if      (b >= 1073741824) printf "%.2f GB", b/1073741824
        else if (b >= 1048576)    printf "%.1f MB", b/1048576
        else if (b >= 1024)       printf "%.0f KB", b/1024
        else                      printf "%d B",    b
    }'
}

# Record an estimated saving: label and byte count written to SAVINGS_FILE
_track_savings() {
    local label="$1" bytes="${2:-0}"
    [ "$bytes" -gt 0 ] 2>/dev/null || bytes=0
    printf '%s\t%s\n' "$bytes" "$label" >> "$SAVINGS_FILE"
}

# Print the sorted savings summary table (called at end of run_clean_all)
print_savings_summary() {
    section "Space Recovery Summary  (sorted by size, largest first)"
    [ -s "$SAVINGS_FILE" ] || { warn "No savings data was collected."; return; }

    # awk reads all rows, stores them, computes total, then prints sorted table
    sort -rn "$SAVINGS_FILE" | awk -F'\t' \
        -v bold="$C_BOLD" -v reset="$C_RESET" \
        -v yellow="$C_YELLOW" -v green="$C_GREEN" -v cyan="$C_CYAN" '
    function human(b,   v, u) {
        if      (b >= 1073741824) { v = b/1073741824; u = "GB" }
        else if (b >= 1048576)    { v = b/1048576;    u = "MB" }
        else if (b >= 1024)       { v = b/1024;       u = "KB" }
        else                      { v = b;             u = " B" }
        return sprintf("%8.1f %s", v, u)
    }
    function bar(n, t,   w, s, i) {
        w = (t > 0) ? int(n * 28 / t) : 0
        s = ""
        for (i = 0; i < w; i++) s = s "#"
        return s
    }
    { bytes[NR]=$1; label[NR]=$2; total+=$1 }
    END {
        sep = "  " \
            "─────────────────────────────────────────" \
            "──────────────────────────────────"
        printf "\n  %s%-38s  %11s  %s%s\n", bold, "Category", "Est. Free", "Proportion", reset
        printf "%s\n", sep
        for (i = 1; i <= NR; i++) {
            printf "  %-38s  %s%11s%s  %s%s%s\n",
                label[i],
                yellow, human(bytes[i]), reset,
                cyan, bar(bytes[i], total), reset
        }
        printf "%s\n", sep
        printf "  %s%-38s  %11s%s\n\n",
            bold green, "TOTAL RECOVERABLE", human(total), reset
    }'
}

# ─── Usage ────────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
${C_BOLD}Usage:${C_RESET} sudo ${PROGNAME} [OPTIONS]

${C_BOLD}Description:${C_RESET}
  Root-only disk usage analyzer. Scans the system for recoverable space,
  presents a summary, and optionally performs cleanup with confirmation.

${C_BOLD}Modes (mutually exclusive):${C_RESET}
  --menu              Interactive numbered menu (default when no mode given)
  --report            Analyze and print report; no cleanup prompts
  --clean-all         Run all cleanup sections (prompts each)
  --auto-clean        Fully non-interactive cleanup — suitable for cron

${C_BOLD}Options:${C_RESET}
  --min-age <days>    Min file age for /tmp sweep  (default: ${TMP_AGE_DAYS})
  --large-mb <MB>     Threshold for large-file scan (default: ${LARGE_FILE_MB})
  --journal-keep <sz> Keep size for journalctl trim  (default: ${JOURNAL_KEEP})
  --dry-run           Show what would be cleaned, do not execute
  -v, --verbose       Enable verbose/debug output (set -x)
  --version           Print version and exit
  -h, --help          Show this help

${C_BOLD}Examples:${C_RESET}
  sudo ${PROGNAME}
  sudo ${PROGNAME} --report
  sudo ${PROGNAME} --clean-all
  sudo ${PROGNAME} --auto-clean --dry-run
  sudo ${PROGNAME} --menu --large-mb 50
EOF
}

# ─── Helpers ──────────────────────────────────────────────────────────────────
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Human-readable du of a path; returns "0" if path does not exist
_du() {
    local path="$1"
    if [ -e "$path" ]; then
        du -sh "$path" 2>/dev/null | awk '{print $1}'
    else
        printf '0'
    fi
}

# Bytes occupied by a path (for arithmetic comparisons)
_du_bytes() {
    local path="$1"
    [ -e "$path" ] || { printf '0'; return; }
    du -sb "$path" 2>/dev/null | awk '{print $1}'
}

confirm() {
    local msg="$1"
    if [ "${AUTO_CLEAN:-0}" -eq 1 ]; then return 0; fi
    printf '%b[?]%b %s [y/N]: ' "$C_YELLOW" "$C_RESET" "$msg"
    local ans
    read -r ans
    case "${ans}" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

_run_clean() {
    # Wrapper: honours --dry-run and logs every cleanup action.
    local desc="$1"; shift
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '%b[DRY-RUN]%b Would run: %s\n' "$C_CYAN" "$C_RESET" "$*"
        _session_log "DRY-RUN: $*"
    else
        log "Running: $*"
        "$@"
        _session_log "CLEANED: ${desc}"
    fi
}

# Print a two-column table row
_row() { printf '  %-40s %b%s%b\n' "$1" "$C_YELLOW" "$2" "$C_RESET"; }

# ─── Guard: root only ─────────────────────────────────────────────────────────
require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        fatal "This script must be run as root. Try: sudo ${PROGNAME}"
    fi
}

# ─── Disk overview ────────────────────────────────────────────────────────────
check_disk_overview() {
    section "Disk Overview"
    df -hT --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs \
        --exclude-type=overlay 2>/dev/null \
        | awk 'NR==1 {printf "%b%s%b\n", "'"$C_BOLD"'", $0, "'"$C_RESET"'"; next} {
            pct=$6+0
            if (pct >= 90) color="'"$C_RED"'"
            else if (pct >= 75) color="'"$C_YELLOW"'"
            else color="'"$C_GREEN"'"
            printf "%s%s%s\n", color, $0, "'"$C_RESET"'"
        }'

    printf '\n'
    printf '%b  Legend: %b>=90%% critical  %b>=75%% warning  %b<75%% healthy%b\n' \
        "$C_DIM" "$C_RED" "$C_YELLOW" "$C_GREEN" "$C_RESET"
}

# ─── Top directories ──────────────────────────────────────────────────────────
check_top_dirs() {
    section "Top 20 Directories by Size"
    printf '%b  (scanning / — skips other filesystems, may take a moment)%b\n' "$C_DIM" "$C_RESET"
    du -x --max-depth=4 / 2>/dev/null \
        | sort -rn \
        | head -20 \
        | awk '{
            gb=$1/1024/1024
            printf "  %8.2f GB   %s\n", gb, $2
        }'
}

# ─── Large files ─────────────────────────────────────────────────────────────
check_large_files() {
    section "Files Larger Than ${LARGE_FILE_MB} MB"
    printf '%b  (searching from / — excludes /proc /sys /dev /run)%b\n' "$C_DIM" "$C_RESET"
    find / \
        -xdev \
        \( -path /proc -o -path /sys -o -path /dev -o -path /run \) -prune \
        -o -type f -size +"${LARGE_FILE_MB}M" -print0 2>/dev/null \
        | xargs -0 -r du -sh 2>/dev/null \
        | sort -rh \
        | head -30 \
        | awk '{printf "  %8s   %s\n", $1, $2}'
}

# ─── APT cache ────────────────────────────────────────────────────────────────
check_apt_cache() {
    section "APT Package Cache  (/var/cache/apt/archives/)"
    command_exists apt-get || { skip "apt-get not found (non-Debian system)"; return; }

    local sz
    sz="$(_du /var/cache/apt/archives/)"
    _row "APT archive cache:" "$sz"
    printf '\n'
    apt-get -s clean 2>/dev/null | head -5 || true
}

clean_apt_cache() {
    command_exists apt-get || return
    local est_bytes est_human
    est_bytes="$(_du_bytes /var/cache/apt/archives/)"
    est_human="$(_bytes_to_human "$est_bytes")"
    _track_savings "APT cache (/var/cache/apt)" "$est_bytes"
    section "Cleaning APT Cache  [~${est_human}]"
    local before after freed
    before="$est_bytes"
    _run_clean "apt clean"       apt-get clean
    _run_clean "apt autoclean"   apt-get autoclean -y
    _run_clean "apt autoremove"  apt-get autoremove -y --purge
    after="$(_du_bytes /var/cache/apt/archives/)"
    freed=$(( (before - after) / 1024 / 1024 ))
    saved "APT cache freed: ~${freed} MB"
}

# ─── Old kernels ─────────────────────────────────────────────────────────────
check_old_kernels() {
    section "Installed Kernels  (old versions are safe to remove)"
    command_exists dpkg || { skip "dpkg not found"; return; }

    local running
    running="$(uname -r)"
    printf '  %bRunning kernel:%b %s\n\n' "$C_GREEN" "$C_RESET" "$running"

    dpkg --list 'linux-image-*' 2>/dev/null \
        | awk '/^ii/{print $2}' \
        | grep -v "$running" \
        | while read -r pkg; do
            local sz
            sz="$(dpkg-query -Wf '${Installed-Size}' "$pkg" 2>/dev/null || printf '?')"
            printf '  %-45s %s kB\n' "$pkg" "$sz"
        done

    printf '\n%b  Tip: sudo apt-get autoremove --purge%b\n' "$C_DIM" "$C_RESET"
}

clean_old_kernels() {
    command_exists apt-get || return
    local running
    running="$(uname -r)"

    local old_kernels
    old_kernels="$(dpkg --list 'linux-image-*' 2>/dev/null \
        | awk '/^ii/{print $2}' \
        | grep -v "$running")" || true

    # Estimate: dpkg reports installed size in kB; convert to bytes
    local est_bytes est_human
    est_bytes="$(printf '%s\n' $old_kernels \
        | while read -r pkg; do
            dpkg-query -Wf '${Installed-Size}\n' "$pkg" 2>/dev/null || printf '0\n'
          done \
        | awk '{t += $1 * 1024} END {print int(t)}')"
    est_bytes="${est_bytes:-0}"
    est_human="$(_bytes_to_human "$est_bytes")"
    _track_savings "Old kernels" "$est_bytes"
    section "Removing Old Kernels  [~${est_human}]"

    if [ -z "$old_kernels" ]; then
        ok "No old kernels found — only the running kernel is installed."
        return
    fi

    printf '  Will remove:\n'
    printf '    %s\n' $old_kernels
    confirm "Remove old kernels?" || { info "Skipped."; return; }

    # shellcheck disable=SC2086
    _run_clean "remove old kernels" apt-get purge -y $old_kernels
    _run_clean "update grub" update-grub
    saved "Old kernels removed."
}

# ─── systemd journal ──────────────────────────────────────────────────────────
check_journal() {
    section "systemd Journal"
    command_exists journalctl || { skip "journalctl not found"; return; }

    journalctl --disk-usage 2>/dev/null || true
    printf '\n'
    _row "Will keep after trim:" "$JOURNAL_KEEP"
}

clean_journal() {
    command_exists journalctl || return
    local est_bytes est_human
    est_bytes="$(_du_bytes /var/log/journal 2>/dev/null || printf '0')"
    est_human="$(_bytes_to_human "$est_bytes")"
    _track_savings "systemd journal (/var/log/journal)" "$est_bytes"
    section "Trimming systemd Journal  [~${est_human} on disk]"
    confirm "Vacuum journal to ${JOURNAL_KEEP}?" || { info "Skipped."; return; }
    _run_clean "journal vacuum" journalctl --vacuum-size="$JOURNAL_KEEP"
    saved "Journal trimmed to ${JOURNAL_KEEP}."
}

# ─── /tmp and /var/tmp ────────────────────────────────────────────────────────
check_tmp() {
    section "Temporary Files  (/tmp  /var/tmp)"
    _row "/tmp total:"     "$(_du /tmp)"
    _row "/var/tmp total:" "$(_du /var/tmp)"
    printf '\n  Files older than %d days:\n' "$TMP_AGE_DAYS"
    find /tmp /var/tmp -maxdepth 3 -mtime +"$TMP_AGE_DAYS" \
        \( -type f -o -type d \) 2>/dev/null \
        | head -20 \
        | while read -r f; do printf '    %s\n' "$f"; done
    local count
    count="$(find /tmp /var/tmp -maxdepth 3 -mtime +"$TMP_AGE_DAYS" 2>/dev/null | wc -l)"
    printf '\n  Total candidates: %b%s%b\n' "$C_YELLOW" "$count" "$C_RESET"
}

clean_tmp() {
    local est_bytes est_human
    est_bytes="$(find /tmp /var/tmp -maxdepth 3 -mtime +"$TMP_AGE_DAYS" \
        \( -type f -o -type d \) -print0 2>/dev/null \
        | xargs -0 -r du -sb 2>/dev/null \
        | awk '{t+=$1} END{print int(t+0)}')"
    est_bytes="${est_bytes:-0}"
    est_human="$(_bytes_to_human "$est_bytes")"
    _track_savings "/tmp and /var/tmp (>${TMP_AGE_DAYS}d old)" "$est_bytes"
    section "Cleaning Temporary Files  (>${TMP_AGE_DAYS} days old)  [~${est_human}]"
    confirm "Delete files in /tmp and /var/tmp older than ${TMP_AGE_DAYS} days?" \
        || { info "Skipped."; return; }
    _run_clean "clean /tmp" \
        find /tmp -maxdepth 3 -mtime +"$TMP_AGE_DAYS" -delete 2>/dev/null || true
    _run_clean "clean /var/tmp" \
        find /var/tmp -maxdepth 3 -mtime +"$TMP_AGE_DAYS" -delete 2>/dev/null || true
    saved "/tmp and /var/tmp old files removed."
}

# ─── Core dumps ───────────────────────────────────────────────────────────────
check_core_dumps() {
    section "Core Dumps"
    local found=0

    if [ -d /var/crash ] && [ -n "$(ls -A /var/crash 2>/dev/null)" ]; then
        _row "/var/crash:" "$(_du /var/crash)"
        ls /var/crash 2>/dev/null | head -5 | while read -r f; do printf '    %s\n' "$f"; done
        found=1
    fi

    if command_exists coredumpctl; then
        local dumps
        dumps="$(coredumpctl list 2>/dev/null | wc -l)"
        [ "$dumps" -gt 1 ] && { _row "systemd coredumps:" "${dumps} entries"; found=1; }
    fi

    local core_count
    core_count="$(find /root /home /tmp /var -maxdepth 4 \
        \( -name 'core' -o -name 'core.[0-9]*' \) -type f 2>/dev/null | wc -l)"
    if [ "$core_count" -gt 0 ]; then
        _row "Loose core files (root/home/tmp/var):" "${core_count} files"
        found=1
    fi

    [ "$found" -eq 0 ] && ok "No core dumps found."
}

clean_core_dumps() {
    local crash_bytes core_bytes est_bytes est_human
    crash_bytes="$(_du_bytes /var/crash)"
    core_bytes="$(find /root /home /tmp /var -maxdepth 4 \
        \( -name 'core' -o -name 'core.[0-9]*' \) -type f -print0 2>/dev/null \
        | xargs -0 -r du -sb 2>/dev/null \
        | awk '{t+=$1} END{print int(t+0)}')"
    core_bytes="${core_bytes:-0}"
    est_bytes=$(( crash_bytes + core_bytes ))
    est_human="$(_bytes_to_human "$est_bytes")"
    _track_savings "Core dumps (/var/crash + loose)" "$est_bytes"
    section "Removing Core Dumps  [~${est_human}]"
    confirm "Remove /var/crash contents and loose core files?" || { info "Skipped."; return; }
    _run_clean "clear /var/crash" \
        find /var/crash -mindepth 1 -delete 2>/dev/null || true
    _run_clean "remove loose core files" \
        find /root /home /tmp /var -maxdepth 4 \
            \( -name 'core' -o -name 'core.[0-9]*' \) -type f -delete 2>/dev/null || true
    if command_exists coredumpctl; then
        _run_clean "flush systemd coredumps" \
            find /var/lib/systemd/coredump -type f -delete 2>/dev/null || true
    fi
    saved "Core dumps removed."
}

# ─── Docker ───────────────────────────────────────────────────────────────────
check_docker() {
    section "Docker"
    command_exists docker || { skip "Docker not installed"; return; }

    docker system df 2>/dev/null || true

    printf '\n'
    local dangling stopped unused_vols
    dangling="$(docker images -f dangling=true -q 2>/dev/null | wc -l)"
    stopped="$(docker ps -a -f status=exited -q 2>/dev/null | wc -l)"
    unused_vols="$(docker volume ls -f dangling=true -q 2>/dev/null | wc -l)"

    _row "Dangling images:"    "$dangling"
    _row "Stopped containers:" "$stopped"
    _row "Unused volumes:"     "$unused_vols"
}

clean_docker() {
    command_exists docker || return
    # Estimate reclaimable bytes from docker system df RECLAIMABLE column (col 5)
    local est_bytes est_human
    est_bytes="$(docker system df 2>/dev/null | awk 'NR>1 && NF>=5 {
        r = $5; val = r+0; gsub(/[0-9.]+/,"",r)
        if      (r ~ /GB|GiB/) val *= 1073741824
        else if (r ~ /MB|MiB/) val *= 1048576
        else if (r ~ /kB|KB|KiB/) val *= 1024
        total += val
    } END { print int(total) }' 2>/dev/null || printf '0')"
    est_bytes="${est_bytes:-0}"
    est_human="$(_bytes_to_human "$est_bytes")"
    _track_savings "Docker (reclaimable)" "$est_bytes"
    section "Docker System Prune  [~${est_human} reclaimable]"
    confirm "Prune stopped containers, unused images, volumes, and build cache?" \
        || { info "Skipped."; return; }
    _run_clean "docker system prune" docker system prune -af --volumes
    saved "Docker resources pruned."
}

# ─── Old log files ────────────────────────────────────────────────────────────
check_old_logs() {
    section "Large / Old Log Files  (/var/log)"
    printf '  Files > 10 MB:\n\n'
    find /var/log -type f -size +10M 2>/dev/null \
        | xargs -r du -sh 2>/dev/null \
        | sort -rh \
        | head -20 \
        | awk '{printf "  %8s   %s\n", $1, $2}'

    printf '\n  Rotated / compressed logs:\n'
    find /var/log -type f \
        \( -name '*.gz' -o -name '*.bz2' -o -name '*.xz' \
           -o -name '*.1' -o -name '*.2' -o -name '*.old' \) 2>/dev/null \
        | xargs -r du -sh 2>/dev/null \
        | sort -rh \
        | head -10 \
        | awk '{printf "  %8s   %s\n", $1, $2}'

    printf '\n'
    _row "/var/log total:" "$(_du /var/log)"
}

clean_old_logs() {
    local est_bytes est_human
    est_bytes="$(find /var/log -type f \
        \( -name '*.gz' -o -name '*.bz2' -o -name '*.xz' \
           -o -name '*.old' -o -name '*.[0-9]' \) -print0 2>/dev/null \
        | xargs -0 -r du -sb 2>/dev/null \
        | awk '{t+=$1} END{print int(t+0)}')"
    est_bytes="${est_bytes:-0}"
    est_human="$(_bytes_to_human "$est_bytes")"
    _track_savings "Old / rotated logs (/var/log)" "$est_bytes"
    section "Cleaning Old / Rotated Logs  [~${est_human}]"
    confirm "Remove compressed rotated logs (.gz .bz2 .xz .old) from /var/log?" \
        || { info "Skipped."; return; }
    _run_clean "remove rotated compressed logs" \
        find /var/log -type f \
            \( -name '*.gz' -o -name '*.bz2' -o -name '*.xz' -o -name '*.old' \) \
            -delete 2>/dev/null || true

    if confirm "Truncate numbered rollover files (.1 .2 etc) — preserves inodes?"; then
        find /var/log -type f -name '*.[0-9]' 2>/dev/null \
            | while read -r f; do
                if [ "$DRY_RUN" -eq 1 ]; then
                    printf '%b[DRY-RUN]%b Would truncate: %s\n' "$C_CYAN" "$C_RESET" "$f"
                else
                    : > "$f"
                    _session_log "TRUNCATED: $f"
                fi
            done
    fi
    saved "Rotated logs cleaned."
}

# ─── Snap old revisions ───────────────────────────────────────────────────────
check_snap() {
    section "Snap Old Revisions"
    command_exists snap || { skip "Snap not installed"; return; }

    snap list --all 2>/dev/null \
        | awk 'NR>1 && /disabled/ {printf "  %-30s rev %-6s %s\n", $1, $3, $6}' \
        | head -20

    local count
    count="$(snap list --all 2>/dev/null | awk '/disabled/{c++} END{print c+0}')"
    printf '\n'
    _row "Disabled snap revisions:" "$count"
}

clean_snap() {
    command_exists snap || return
    local count
    count="$(snap list --all 2>/dev/null | awk '/disabled/{c++} END{print c+0}')"

    # Estimate from squashfs snap files on disk: /var/lib/snapd/snaps/<name>_<rev>.snap
    local est_bytes est_human
    est_bytes="$(snap list --all 2>/dev/null \
        | awk '/disabled/{print $1, $3}' \
        | while read -r name rev; do
            f="/var/lib/snapd/snaps/${name}_${rev}.snap"
            [ -f "$f" ] && du -b "$f" 2>/dev/null | awk '{print $1}' || printf '0\n'
          done \
        | awk '{t+=$1} END{print int(t+0)}')"
    est_bytes="${est_bytes:-0}"
    est_human="$(_bytes_to_human "$est_bytes")"
    _track_savings "Snap disabled revisions" "$est_bytes"
    section "Removing Old Snap Revisions  [~${est_human}]"
    [ "$count" -eq 0 ] && { ok "No disabled snap revisions."; return; }

    confirm "Remove ${count} disabled snap revision(s)?" || { info "Skipped."; return; }
    snap list --all 2>/dev/null \
        | awk '/disabled/{print $1, $3}' \
        | while read -r name rev; do
            _run_clean "snap remove $name rev $rev" \
                snap remove "$name" --revision="$rev" 2>/dev/null || true
        done
    saved "Old snap revisions removed."
}

# ─── User caches ──────────────────────────────────────────────────────────────
check_user_caches() {
    section "User Cache Directories  (~/.cache)"
    printf '  Top consumers per user:\n\n'

    local homedir user sz
    for homedir in /root /home/*/; do
        [ -d "${homedir}/.cache" ] || continue
        user="$(basename "$homedir")"
        sz="$(_du "${homedir}/.cache")"
        _row "  ${user}/.cache:" "$sz"

        du -sh "${homedir}/.cache"/*/ 2>/dev/null \
            | sort -rh \
            | head -5 \
            | awk '{printf "        %-35s %s\n", $2, $1}'
    done

    printf '\n  Developer tool caches:\n\n'
    local npm_cache pip_cache composer_cache
    npm_cache="${XDG_CACHE_HOME:-${HOME}/.cache}/npm"
    command_exists npm && npm_cache="$(npm config get cache 2>/dev/null || printf "$npm_cache")"
    pip_cache="${XDG_CACHE_HOME:-${HOME}/.cache}/pip"
    command_exists pip3 && pip_cache="$(pip3 cache dir 2>/dev/null || printf "$pip_cache")"
    composer_cache="${COMPOSER_CACHE_DIR:-/root/.composer/cache}"

    [ -d "$npm_cache" ]      && _row "  npm cache:"           "$(_du "$npm_cache")"
    [ -d "$pip_cache" ]      && _row "  pip cache:"           "$(_du "$pip_cache")"
    [ -d "$composer_cache" ] && _row "  composer cache:"      "$(_du "$composer_cache")"
    [ -d /root/.composer/cache ] && _row "  composer (root):" "$(_du /root/.composer/cache)"
}

clean_user_caches() {
    # Estimate: sum of all ~/.cache directories across all users
    local est_bytes=0 h b
    for h in /root /home/*/; do
        [ -d "${h}/.cache" ] || continue
        b="$(_du_bytes "${h}/.cache")"
        est_bytes=$(( est_bytes + b ))
    done
    local est_human
    est_human="$(_bytes_to_human "$est_bytes")"
    _track_savings "User caches (~/.cache + dev tools)" "$est_bytes"
    section "Cleaning User Caches  [~${est_human}]"

    # npm
    if command_exists npm; then
        local npm_cache
        npm_cache="$(npm config get cache 2>/dev/null || printf '')"
        if [ -d "${npm_cache:-}" ]; then
            confirm "Clean npm cache (${npm_cache})?" && {
                _run_clean "npm cache clean" npm cache clean --force 2>/dev/null || true
                saved "npm cache cleared."
            }
        fi
    fi

    # pip
    if command_exists pip3; then
        local pip_cache
        pip_cache="$(pip3 cache dir 2>/dev/null || printf '')"
        if [ -d "${pip_cache:-}" ]; then
            confirm "Clean pip cache (${pip_cache})?" && {
                _run_clean "pip cache purge" pip3 cache purge 2>/dev/null || true
                saved "pip cache cleared."
            }
        fi
    fi

    # Composer
    for cc in "${HOME}/.composer/cache" /root/.composer/cache; do
        [ -d "$cc" ] || continue
        confirm "Clean composer cache (${cc})?" && {
            _run_clean "composer cache clear" \
                composer clear-cache 2>/dev/null \
                || rm -rf "${cc:?}/"* 2>/dev/null || true
            saved "Composer cache cleared."
        }
    done

    # ~/.cache per user (skip browser profile dirs — those are precious)
    for homedir in /root /home/*/; do
        [ -d "${homedir}/.cache" ] || continue
        local user sz
        user="$(basename "$homedir")"
        sz="$(_du "${homedir}/.cache")"
        if confirm "Clear ${user}/.cache (${sz})? (browser dirs preserved)"; then
            _run_clean "clear ${user} cache" \
                find "${homedir}/.cache" -mindepth 1 -maxdepth 1 \
                    \( -name 'mozilla' -o -name 'google-chrome' \
                       -o -name 'chromium' -o -name 'BraveSoftware' \) \
                    -prune \
                    -o -print0 \
                    | xargs -0 -r rm -rf 2>/dev/null || true
            saved "${user}/.cache cleared."
        fi
    done
}

# ─── Thumbnail caches ─────────────────────────────────────────────────────────
check_thumbnails() {
    section "Thumbnail Caches  (~/.cache/thumbnails)"
    local found=0
    for homedir in /root /home/*/; do
        local thumb="${homedir}/.cache/thumbnails"
        [ -d "$thumb" ] || continue
        local user sz
        user="$(basename "$homedir")"
        sz="$(_du "$thumb")"
        _row "  ${user} thumbnails:" "$sz"
        found=1
    done
    [ "$found" -eq 0 ] && ok "No thumbnail caches found."
}

clean_thumbnails() {
    local est_bytes=0 h b
    for h in /root /home/*/; do
        [ -d "${h}/.cache/thumbnails" ] || continue
        b="$(_du_bytes "${h}/.cache/thumbnails")"
        est_bytes=$(( est_bytes + b ))
    done
    local est_human
    est_human="$(_bytes_to_human "$est_bytes")"
    _track_savings "Thumbnail caches (~/.cache/thumbnails)" "$est_bytes"
    section "Cleaning Thumbnail Caches  [~${est_human}]"
    for homedir in /root /home/*/; do
        local thumb="${homedir}/.cache/thumbnails"
        [ -d "$thumb" ] || continue
        local user sz
        user="$(basename "$homedir")"
        sz="$(_du "$thumb")"
        confirm "Clear ${user} thumbnails (${sz})?" && {
            _run_clean "clear ${user} thumbnails" rm -rf "${thumb:?}/"* 2>/dev/null || true
            saved "${user} thumbnails cleared."
        }
    done
}

# ─── Orphaned packages ────────────────────────────────────────────────────────
check_orphans() {
    section "Orphaned / Unused Packages"
    command_exists apt-get || { skip "apt-get not found"; return; }

    if command_exists deborphan; then
        local orphans
        orphans="$(deborphan 2>/dev/null | wc -l)"
        _row "Orphaned packages (deborphan):" "$orphans"
        deborphan 2>/dev/null | head -20 | while read -r p; do printf '    %s\n' "$p"; done
    else
        warn "deborphan not installed. Install: apt-get install deborphan"
    fi

    printf '\n  Packages no longer required (autoremove candidates):\n'
    apt-get --assume-no autoremove 2>/dev/null | grep "^  " | head -20 || true
}

clean_orphans() {
    command_exists apt-get || return
    # Estimate: sum installed sizes of deborphan packages (dpkg reports kB)
    local est_bytes est_human
    if command_exists deborphan; then
        est_bytes="$(deborphan 2>/dev/null \
            | while read -r pkg; do
                dpkg-query -Wf '${Installed-Size}\n' "$pkg" 2>/dev/null || printf '0\n'
              done \
            | awk '{t += $1 * 1024} END {print int(t+0)}')"
    fi
    est_bytes="${est_bytes:-0}"
    est_human="$(_bytes_to_human "$est_bytes")"
    _track_savings "Orphaned packages (deborphan)" "$est_bytes"
    section "Removing Orphaned Packages  [~${est_human}]"

    if command_exists deborphan; then
        local orphans
        orphans="$(deborphan 2>/dev/null)"
        if [ -n "$orphans" ]; then
            printf '%s\n' "$orphans"
            confirm "Remove deborphan packages?" && {
                # shellcheck disable=SC2086
                _run_clean "remove deborphan packages" apt-get purge -y $orphans
                saved "Orphaned packages removed."
            }
        fi
    fi

    confirm "Run apt autoremove --purge?" && {
        _run_clean "apt autoremove" apt-get autoremove -y --purge
        saved "apt autoremove complete."
    }
}

# ─── Flatpak ──────────────────────────────────────────────────────────────────
check_flatpak() {
    section "Flatpak Unused Runtimes"
    command_exists flatpak || { skip "Flatpak not installed"; return; }

    flatpak uninstall --unused --assumeyes --dry-run 2>/dev/null || true
}

clean_flatpak() {
    command_exists flatpak || return
    # Estimate via squashfs mount dirs for unused runtimes
    local est_bytes est_human
    est_bytes="$(flatpak uninstall --unused --dry-run 2>/dev/null \
        | grep -oE '^[[:space:]]+[A-Za-z].*' \
        | awk '{print $1}' \
        | while read -r ref; do
            # ref format: name/arch/branch — look in system installation
            local dir="/var/lib/flatpak/runtime/${ref}"
            [ -d "$dir" ] && du -sb "$dir" 2>/dev/null | awk '{print $1}' || printf '0\n'
          done \
        | awk '{t+=$1} END{print int(t+0)}')"
    est_bytes="${est_bytes:-0}"
    est_human="$(_bytes_to_human "$est_bytes")"
    _track_savings "Flatpak unused runtimes" "$est_bytes"
    section "Removing Unused Flatpak Runtimes  [~${est_human}]"
    confirm "Remove unused Flatpak runtimes?" || { info "Skipped."; return; }
    _run_clean "flatpak uninstall unused" flatpak uninstall --unused -y 2>/dev/null || true
    saved "Unused Flatpak runtimes removed."
}

# ─── Crash reports ────────────────────────────────────────────────────────────
check_crash_reports() {
    section "Crash Reports  (/var/crash  /var/lib/apport)"
    local found=0
    for d in /var/crash /var/lib/apport/coredump; do
        [ -d "$d" ] && [ -n "$(ls -A "$d" 2>/dev/null)" ] && {
            _row "$d:" "$(_du "$d")"
            ls "$d" 2>/dev/null | head -5 | while read -r f; do printf '    %s\n' "$f"; done
            found=1
        }
    done
    [ "$found" -eq 0 ] && ok "No crash reports found."
}

# ─── Full report (read-only, all sections) ───────────────────────────────────
run_report() {
    require_root
    check_disk_overview
    check_apt_cache
    check_old_kernels
    check_journal
    check_tmp
    check_core_dumps
    check_docker
    check_old_logs
    check_snap
    check_user_caches
    check_thumbnails
    check_orphans
    check_flatpak
    check_crash_reports

    section "Report Complete"
    printf '  %bNo changes were made.%b\n' "$C_DIM" "$C_RESET"
    printf '  Re-run with --menu or --clean-all to reclaim space.\n'
    printf '  Session log: %s\n' "$SESSION_LOG"
}

# ─── Clean all ────────────────────────────────────────────────────────────────
run_clean_all() {
    require_root
    check_disk_overview

    clean_apt_cache
    clean_old_kernels
    clean_journal
    clean_tmp
    clean_core_dumps
    clean_docker
    clean_old_logs
    clean_snap
    clean_user_caches
    clean_thumbnails
    clean_orphans
    clean_flatpak

    print_savings_summary
    section "All Cleanup Sections Complete"
    check_disk_overview
    printf '  Session log: %s\n' "$SESSION_LOG"
}

# ─── Interactive menu ─────────────────────────────────────────────────────────
run_menu() {
    require_root
    local choice

    while true; do
        # Dynamic header: show busiest filesystem
        local top_fs top_pct
        top_fs="$(df -h --exclude-type=tmpfs --exclude-type=devtmpfs \
            --exclude-type=squashfs 2>/dev/null \
            | awk 'NR>1 {gsub(/%/,"",$5); if($5>max){max=$5; fs=$6}} END{print fs}')"
        top_pct="$(df -h --exclude-type=tmpfs --exclude-type=devtmpfs \
            --exclude-type=squashfs 2>/dev/null \
            | awk 'NR>1 {gsub(/%/,"",$5); if($5>max){max=$5; pct=$5}} END{print pct+0}')"

        local pct_color="$C_GREEN"
        [ "${top_pct:-0}" -ge 75 ] && pct_color="$C_YELLOW"
        [ "${top_pct:-0}" -ge 90 ] && pct_color="$C_RED"

        printf '\n%b╔═══════════════════════════════════════════════╗%b\n' \
            "${C_BOLD}${C_CYAN}" "$C_RESET"
        printf '%b║  Disk Analyzer  v%-6s                        ║%b\n' \
            "${C_BOLD}${C_CYAN}" "$SCRIPT_VERSION" "$C_RESET"
        printf '%b╚═══════════════════════════════════════════════╝%b\n' \
            "${C_BOLD}${C_CYAN}" "$C_RESET"
        printf '  Busiest mount: %b%-20s%b  %b%s%%%b\n\n' \
            "$C_WHITE" "${top_fs:-(none)}" "$C_RESET" \
            "$pct_color" "${top_pct:-0}" "$C_RESET"

        cat <<'MENU'
  ── Analysis (read-only) ──────────────────────
   1)  Disk overview  (df)
   2)  Top 20 directories by size
   3)  Large files  (>100 MB)
   4)  APT cache
   5)  Old kernels
   6)  systemd journal
   7)  /tmp and /var/tmp
   8)  Core dumps
   9)  Docker
  10)  Old log files
  11)  Snap old revisions
  12)  User caches  (npm / pip / ~/.cache)
  13)  Thumbnail caches
  14)  Orphaned packages
  15)  Flatpak unused runtimes
  16)  Crash reports
  17)  Full report  (all checks — no cleanup)

  ── Cleanup (with confirmation) ───────────────
  18)  Clean: APT cache
  19)  Clean: Old kernels
  20)  Clean: systemd journal
  21)  Clean: /tmp and /var/tmp
  22)  Clean: Core dumps
  23)  Clean: Docker
  24)  Clean: Old log files
  25)  Clean: Snap old revisions
  26)  Clean: User caches
  27)  Clean: Thumbnail caches
  28)  Clean: Orphaned packages
  29)  Clean: Flatpak runtimes
  30)  Clean: ALL sections  (with confirm each)

   0)  Exit

MENU

        printf '%bChoice [0-30]: %b' "$C_BOLD" "$C_RESET"
        read -r choice

        case "$choice" in
            1)  check_disk_overview ;;
            2)  check_top_dirs ;;
            3)  check_large_files ;;
            4)  check_apt_cache ;;
            5)  check_old_kernels ;;
            6)  check_journal ;;
            7)  check_tmp ;;
            8)  check_core_dumps ;;
            9)  check_docker ;;
            10) check_old_logs ;;
            11) check_snap ;;
            12) check_user_caches ;;
            13) check_thumbnails ;;
            14) check_orphans ;;
            15) check_flatpak ;;
            16) check_crash_reports ;;
            17) run_report ;;
            18) clean_apt_cache ;;
            19) clean_old_kernels ;;
            20) clean_journal ;;
            21) clean_tmp ;;
            22) clean_core_dumps ;;
            23) clean_docker ;;
            24) clean_old_logs ;;
            25) clean_snap ;;
            26) clean_user_caches ;;
            27) clean_thumbnails ;;
            28) clean_orphans ;;
            29) clean_flatpak ;;
            30) run_clean_all ;;
            0|q|Q)
                info "Session log: ${SESSION_LOG}"
                exit 0
                ;;
            '') continue ;;
            *)  warn "Invalid choice '${choice}'. Enter a number 0-30." ;;
        esac

        printf '\n%b  Press ENTER to return to menu...%b ' "$C_DIM" "$C_RESET"
        read -r _dummy || true
    done
}

# ─── Argument parsing ─────────────────────────────────────────────────────────
MODE="menu"
AUTO_CLEAN=0

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --menu)
                MODE="menu"
                shift
                ;;
            --report)
                MODE="report"
                shift
                ;;
            --clean-all)
                MODE="clean-all"
                shift
                ;;
            --auto-clean)
                MODE="clean-all"
                AUTO_CLEAN=1
                shift
                ;;
            --dry-run)
                DRY_RUN=1
                shift
                ;;
            --min-age)
                shift
                [ -z "${1:-}" ] && fatal "--min-age requires a number of days"
                TMP_AGE_DAYS="$1"
                shift
                ;;
            --large-mb)
                shift
                [ -z "${1:-}" ] && fatal "--large-mb requires a number in MB"
                LARGE_FILE_MB="$1"
                shift
                ;;
            --journal-keep)
                shift
                [ -z "${1:-}" ] && fatal "--journal-keep requires a size string (e.g. 200M)"
                JOURNAL_KEEP="$1"
                shift
                ;;
            -v|--verbose)
                VERBOSE=1
                set -x
                shift
                ;;
            --version)
                printf '%s version %s\n' "$PROGNAME" "$SCRIPT_VERSION"
                exit 0
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                fatal "Unknown option: '$1'. Run '${PROGNAME} --help' for usage."
                ;;
        esac
    done
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
    if [ "$#" -eq 0 ]; then
        require_root
        run_menu
        exit 0
    fi

    parse_args "$@"

    [ "$DRY_RUN" -eq 1 ] && warn "DRY-RUN mode — no changes will be made."

    case "$MODE" in
        menu)      run_menu ;;
        report)    run_report ;;
        clean-all) run_clean_all ;;
        *)         fatal "Internal error: unknown mode '${MODE}'" ;;
    esac
}

main "$@"
