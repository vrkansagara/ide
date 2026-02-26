#!/usr/bin/env bash
# ==============================================================================
# jmeter.sh — Download, verify, and install Apache JMeter
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

  Download Apache JMeter, verify its GPG signature, extract it to
  ~/Applications, and make the jmeter binary executable.

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

    readonly JMETER_VERSION="apache-jmeter-5.6.3"

    section "Downloading JMeter"
    cd /tmp
    _run rm -rf "/tmp/${JMETER_VERSION}"*

    wget -k "https://dlcdn.apache.org//jmeter/binaries/${JMETER_VERSION}.tgz"
    wget -k "https://www.apache.org/dist/jmeter/binaries/${JMETER_VERSION}.tgz.asc"

    section "Verifying GPG signature"
    gpg --keyserver pgpkeys.mit.edu --recv-key C4923F9ABFB2F1A06F08E88BAC214CAA0612B399
    # gpg --fingerprint C4923F9ABFB2F1A06F08E88BAC214CAA0612B399

    if gpg --verify "${JMETER_VERSION}.tgz.asc" "${JMETER_VERSION}.tgz"; then
        section "Extracting and installing JMeter"
        tar -xvf "${JMETER_VERSION}.tgz"
        mv "/tmp/${JMETER_VERSION}" /tmp/apache-jmeter
        rm -rf "$HOME/Applications/apache-jmeter"
        mv /tmp/apache-jmeter "$HOME/Applications"
    else
        fatal "GPG signature verification failed for ${JMETER_VERSION}.tgz"
    fi

    _run chmod ugo+xr "$HOME/Applications/apache-jmeter/bin/jmeter"
    info "JMeter binary: $HOME/Applications/apache-jmeter/bin/jmeter"

    ok "Apache JMeter installation complete."
    exit 0
}

main "$@"
