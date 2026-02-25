#!/usr/bin/env bash
# ==============================================================================
# brightness-light.sh — control monitor brightness via xrandr
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0

set -o errexit
set -o pipefail
set -o nounset

readonly VERSION="2.0.0"
readonly PROGNAME="${0##*/}"
VERBOSE=0
SUDO_CMD=""

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

info()    { printf '%b[INFO]  %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
warn()    { printf '%b[WARN]  %s%b\n' "$C_YELLOW" "$*" "$C_RESET"; }
fatal()   { printf '%b[FATAL] %s%b\n' "$C_RED"    "$*" "$C_RESET" >&2; exit 1; }
ok()      { printf '%b[OK]    %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
log()     { [ "$VERBOSE" -ne 0 ] && printf '[DEBUG] %s\n' "$*" || true; }
section() { printf '\n%b=== %s ===%b\n' "${C_BOLD}${C_CYAN}" "$*" "$C_RESET"; }

usage() {
    printf 'Usage: %s [OPTIONS] <level>\n\n' "$PROGNAME"
    printf 'Bash script to control the monitor brightness via xrandr.\n'
    printf 'Where <level> ranges from 0 to 100.\n\n'
    printf 'Options:\n'
    printf '  -v, --verbose    Enable verbose/debug output\n'
    printf '      --version    Print version and exit\n'
    printf '  -h, --help       Show this help message\n'
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

parse_args() {
    LEVEL=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose)  VERBOSE=1 ;;
            --version)     printf '%s version %s\n' "$PROGNAME" "$VERSION"; exit 0 ;;
            -h|--help)     usage; exit 0 ;;
            -*)            fatal "Unknown option: $1" ;;
            *)             LEVEL="$1" ;;
        esac
        shift
    done
}

main() {
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
    log "Started at ${CURRENT_DATE}"

    SYNTAX="\n\tSYNTAX: ${PROGNAME} level\n\tWhere 'level' ranges from 0 to 100.\n"

    ORIGINAL_LEVEL=$(xrandr --verbose | grep -m 1 -i brightness | cut -f2 -d ' ')
    info "Original brightness level is: ${ORIGINAL_LEVEL}"

    if [ -z "$LEVEL" ]; then
        printf '%b' "$SYNTAX"
        exit 1
    fi

    if [[ "$LEVEL" -gt 100 ]]; then
        printf '%b' "$SYNTAX"
        exit 1
    fi

    if [[ "$LEVEL" -lt 0 ]]; then
        printf '%b' "$SYNTAX"
        exit 1
    fi

    brightness_level="$(( LEVEL / 100 )).$(( LEVEL % 100 ))"
    screenname=$(xrandr | grep " connected" | cut -f1 -d" ")
    xrandr --output "$screenname" --brightness "$brightness_level"
    ok "Screen brightness level set to ${LEVEL}%"
}
main "$@"
