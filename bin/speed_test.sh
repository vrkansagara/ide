#!/usr/bin/env bash
# ==============================================================================
# speed_test.sh — Measures HTTP response time for a URL over multiple requests
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0

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

# ------------------------------------------------------------------------------
# Usage
# ------------------------------------------------------------------------------
usage() {
    cat <<EOF
Usage: $PROGNAME [OPTIONS] <url>

Measures HTTP response time for a given URL over 10 requests using curl,
then prints total, lowest, average, and highest response times.

Arguments:
  <url>   The URL to test (e.g. https://example.com)

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message

Example:
  $PROGNAME https://example.com
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

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    parse_args "$@"
    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    if [ $# -lt 1 ]; then
        usage
        exit 1
    fi

    local url="$1"
    local TOTAL=0
    local COUNT=10
    local HIGHEST="false"
    local LOWEST="false"
    local TIME=""

    section "Speed Test: $url"

    for ((i=1; i<=COUNT; i++)); do
        info "($i/$COUNT) CURL for $url $(date '+%Y%m%d%H%M%S')"
        TIME=$(curl -o /dev/null -s -w '%{time_total}\n' "$url")
        TOTAL=$(printf '%s' "$TOTAL+$TIME" | bc)

        if [ "$HIGHEST" = "false" ] || [ "$(printf '%s' "$HIGHEST < $TIME" | bc -l)" -gt 0 ]; then
            HIGHEST="$TIME"
        fi

        if [ "$LOWEST" = "false" ] || [ "$(printf '%s' "$LOWEST > $TIME" | bc -l)" -gt 0 ]; then
            LOWEST="$TIME"
        fi
    done

    local AVERAGE
    AVERAGE=$(printf 'scale=4; %s/%s' "$TOTAL" "$COUNT" | bc)

    section "Speed Test Results for [ $url ]"
    info "total:   $TOTAL"
    info "lowest:  $LOWEST"
    info "average: $AVERAGE"
    info "highest: $HIGHEST"
    ok "Speed test done for [ $url ]"
}

main "$@"
