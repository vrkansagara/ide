#!/usr/bin/env bash
# ==============================================================================
# elasticsearch.sh — Install Elasticsearch 7.x on Ubuntu/Debian
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
    cat <<EOF
Usage: $PROGNAME [-v|--verbose] [--version] [-h|--help]

Description:
  Installs Elasticsearch 7.x on Ubuntu/Debian by adding the official Elastic
  APT repository and GPG key, then installing via apt-get.

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

    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | _run apt-key add -
    _run apt-get install apt-transport-https
    _run apt-get install apt-transport-https
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | _run tee /etc/apt/sources.list.d/elastic-7.x.list
    _run apt-get update && _run apt-get install elasticsearch

    # /etc/security/limits.conf
    # Ensure ElasticSearch can open files and lock memory!
    # elasticsearch soft nofile 65536
    # elasticsearch hard nofile 65536
    # elasticsearch - memlock unlimited

    # /etc/security/limits.conf,
    # allow user 'elasticsearch' mlockall
    # elasticsearch soft memlock unlimited
    # elasticsearch hard memlock unlimited
}
main "$@"
