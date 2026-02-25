#!/usr/bin/env bash
# ==============================================================================
# flux.sh — Install fluxgui (brightness dimming after sunset and sunrise)
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# Note       : Brightness dim after sunset and sunrise
# Github     : https://github.com/xflux-gui/fluxgui

set -o errexit
set -o pipefail
set -o nounset

readonly VERSION="2.0.0"
readonly PROGNAME="${0##*/}"
VERBOSE=0
SUDO_CMD=""

CURRENT_DATE="$(date "+%Y%m%d%H%M%S")"
export CURRENT_DATE

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
    cat <<EOF
Usage: $PROGNAME [-v|--verbose] [--version] [-h|--help]

Description:
  Installs fluxgui from the PPA ppa:nathan-renniewaldock/flux to provide
  automatic screen brightness adjustment based on time of day.

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message and exit
EOF
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

parse_args() {
    while [ "${1:-}" != "" ]; do
        case "$1" in
            -v | --verbose)
                VERBOSE=1
                set -x
                ;;
            --version)
                printf '%s version %s\n' "$PROGNAME" "$VERSION"
                exit 0
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            *)
                warn "Unknown argument: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done
}

main() {
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    _run add-apt-repository ppa:nathan-renniewaldock/flux
    _run apt-get update
    _run apt-get install -y fluxgui
}
main "$@"
