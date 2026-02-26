#!/usr/bin/env bash
# ==============================================================================
# speedtest.sh — Install Speedtest CLI and run a speed test
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# URL        : https://www.speedtest.net/apps/cli
# Usage      : Can be scheduled via cron every 15 minutes:
#   */15 * * * * sh $HOME/.vim/src/Sh/System/speedtest.sh >> /dev/null 2>&1

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

  Install shellcheck and Speedtest CLI if not present, then run a speed test
  and append the results to /tmp/speedtest.txt.

  To remove prior bintray-based installs first:
    sudo rm /etc/apt/sources.list.d/speedtest.list
    sudo apt-get update
    sudo apt-get remove speedtest speedtest-cli

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

    section "Checking for shellcheck"
    if ! command -v shellcheck &>/dev/null; then
        info "Installing shellcheck for shell script sanitization"
        _run apt-get install shellcheck
    fi

    section "Checking for speedtest"
    if ! command -v speedtest &>/dev/null; then
        info "Installing Speedtest CLI"
        _run apt-get install curl
        curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | _run bash
        _run apt-get install speedtest-cli
    fi

    section "Running speed test"
    if command -v speedtest &>/dev/null; then
        # speedtest -p no > /tmp/speedtest-"${current_date}".txt
        info "Speed test started at [ $(date) ]" | tee -a /tmp/speedtest.txt
        speedtest --secure | tee -a /tmp/speedtest.txt
    fi

    ok "Speed test complete. Results appended to /tmp/speedtest.txt"
    exit 0
}

main "$@"
