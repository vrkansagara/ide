#!/usr/bin/env bash
# ==============================================================================
# os.sh — Detect and display the Linux distribution name and version
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

on_error() {
    local code=$? line="${BASH_LINENO[0]}"
    warn "Unexpected failure at line ${line} (exit ${code})."
    exit "${code}"
}
trap on_error ERR

usage() {
    cat <<EOF
Usage: ${PROGNAME} [OPTIONS]

  Detect the Linux distribution and version using multiple detection methods
  (os-release, lsb_release, /etc/lsb-release, /etc/debian_version, uname).

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message
EOF
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose)
                VERBOSE=1
                set -x
                shift
                ;;
            --version)
                printf '%s\n' "$VERSION"
                exit 0
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                fatal "Unknown option: $1"
                ;;
        esac
    done
}

main() {
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    local OS=""
    local VER=""

    section "Detecting OS"
    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        # shellcheck source=/dev/null
        . /etc/os-release
        OS="$NAME"
        VER="$VERSION_ID"
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS="$(lsb_release -si)"
        VER="$(lsb_release -sr)"
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        # shellcheck source=/dev/null
        . /etc/lsb-release
        OS="$DISTRIB_ID"
        VER="$DISTRIB_RELEASE"
    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        OS="Debian"
        VER="$(cat /etc/debian_version)"
    elif [ -f /etc/SuSe-release ]; then
        # Older SuSE/etc.
        OS="SuSE"
        VER="(unknown)"
    elif [ -f /etc/redhat-release ]; then
        # Older Red Hat, CentOS, etc.
        OS="RedHat"
        VER="(unknown)"
    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        OS="$(uname -s)"
        VER="$(uname -r)"
    fi

    printf 'Linux name     :- %s\n' "$OS"
    printf 'Linux version  :- %s\n' "$VER"

    ok "OS detection complete."
    exit 0
}

main "$@"
