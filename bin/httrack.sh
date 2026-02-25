#!/usr/bin/env bash
# ==============================================================================
# httrack.sh — Enterprise HTTrack website downloader wrapper
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# HTTrack Version: 3.49-5

set -o errexit
set -o pipefail
set -o nounset

# ------------------------------------------------------------------------------
# Constants + state
# ------------------------------------------------------------------------------
readonly VERSION="2.0.0"
readonly PROGNAME="${0##*/}"
VERBOSE=0
SUDO_CMD=""

# -------------------------
# Configuration Defaults
# -------------------------
HTTRACK_BIN="$(command -v httrack 2>/dev/null || true)"
LOG_DIR="./logs"
DATE_TAG="$(date +%Y%m%d_%H%M%S)"
MAX_CONN=5
MAX_RATE=250000     # bytes/sec (~250 KB/s)
TIMEOUT=30
RETRIES=3
MIN_DISK_MB=500
WEBSITE_URL=""
OUTPUT_DIR=""
LOG_FILE=""

# ------------------------------------------------------------------------------
# Color block
# ------------------------------------------------------------------------------
_init_colors() {
    if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
        C_RESET="$(tput sgr0   2>/dev/null || printf '')"; C_GREEN="$(tput setaf 2 2>/dev/null || printf '')"
        C_YELLOW="$(tput setaf 3 2>/dev/null || printf '')"; C_RED="$(tput setaf 1 2>/dev/null || printf '')"
        C_CYAN="$(tput setaf 6  2>/dev/null || printf '')"; C_BOLD="$(tput bold   2>/dev/null || printf '')"
    else
        C_RESET=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''; C_BOLD=''
    fi
}
_init_colors

# ------------------------------------------------------------------------------
# Logging helpers
# ------------------------------------------------------------------------------
info()    { printf '%b[INFO]  %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
warn()    { printf '%b[WARN]  %s%b\n' "$C_YELLOW" "$*" "$C_RESET"; }
fatal()   { printf '%b[FATAL] %s%b\n' "$C_RED"    "$*" "$C_RESET" >&2; exit 1; }
ok()      { printf '%b[OK]    %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
log()     { [ "$VERBOSE" -ne 0 ] && printf '[DEBUG] %s\n' "$*" || true; }
section() { printf '\n%b=== %s ===%b\n' "${C_BOLD}${C_CYAN}" "$*" "$C_RESET"; }

# Log to both stdout and log file
htlog() {
    printf '[%s] %s\n' "${DATE_TAG}" "$*" | tee -a "${LOG_FILE:-/dev/null}"
}

# ------------------------------------------------------------------------------
# Usage
# ------------------------------------------------------------------------------
usage() {
    cat <<EOF
Usage: $PROGNAME [OPTIONS] <website_url> <output_directory>

Downloads a website using HTTrack (version 3.49-5).

Arguments:
  <website_url>        The URL of the website to download
  <output_directory>   The local directory to save the downloaded site

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message

Example:
  $PROGNAME https://example.com /data/backups/example
  $PROGNAME https://birdiebadminton.in birdiebadminton.in-html
EOF
}

# ------------------------------------------------------------------------------
# Sudo wrapper
# ------------------------------------------------------------------------------
_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

# ------------------------------------------------------------------------------
# Argument parsing
# ------------------------------------------------------------------------------
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose) VERBOSE=1; set -x; shift ;;
            --version)    printf '%s v%s\n' "$PROGNAME" "$VERSION"; exit 0 ;;
            -h|--help)    usage; exit 0 ;;
            --)           shift; break ;;
            -*)           fatal "Unknown option: '$1'. Use -h for help." ;;
            *)            break ;;
        esac
    done
}

# -------------------------
# Helper Functions
# -------------------------
check_binary() {
    if [ -z "$HTTRACK_BIN" ]; then
        fatal "httrack not found. Please install HTTrack 3.49-5"
    fi
}

check_disk_space() {
    local avail
    avail=$(df -Pm "$OUTPUT_DIR" | awk 'NR==2 {print $4}')
    if [ "$avail" -lt "$MIN_DISK_MB" ]; then
        fatal "Not enough disk space. Required: ${MIN_DISK_MB}MB, available: ${avail}MB"
    fi
}

sanitize_url() {
    WEBSITE_URL="${WEBSITE_URL%/}"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    parse_args "$@"
    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    # Require exactly 2 positional arguments
    if [ $# -ne 2 ]; then
        usage
        exit 1
    fi

    WEBSITE_URL="$1"
    OUTPUT_DIR="$2"

    check_binary
    sanitize_url

    mkdir -p "$OUTPUT_DIR" "$LOG_DIR"
    LOG_FILE="${LOG_DIR}/httrack_$(printf '%s' "$WEBSITE_URL" | sed 's~https\?://~~;s~/~_~g')_${DATE_TAG}.log"

    check_disk_space

    section "HTTrack Website Downloader"
    htlog "HTTrack Version: $("$HTTRACK_BIN" --version 2>&1 | head -1 || true)"
    htlog "Target Website: $WEBSITE_URL"
    htlog "Output Directory: $OUTPUT_DIR"

    # -------------------------
    # HTTrack Execution
    # -------------------------
    info "Starting website download..."

    EXIT_CODE=0
    httrack "https://birdiebadminton.in" \
        -O "birdiebadminton.in-html" \
        --continue \
        --depth=5 \
        --ext-depth=2 \
        --sockets="$MAX_CONN" \
        --timeout="$TIMEOUT" \
        --retries="$RETRIES" \
        --verbose || EXIT_CODE=$?

    # -------------------------
    # Post Execution
    # -------------------------
    if [ "$EXIT_CODE" -eq 0 ]; then
        htlog "Download completed successfully"
        ok "Download completed successfully."
    else
        htlog "Download completed with errors (exit code: $EXIT_CODE)"
        warn "Download completed with errors (exit code: $EXIT_CODE)"
    fi

    exit "$EXIT_CODE"
}

main "$@"
