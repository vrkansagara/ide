#!/usr/bin/env bash
# ==============================================================================
# kernel-debug.sh — Install Linux kernel debug symbols for Ubuntu/Debian
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# Ref        : https://askubuntu.com/questions/197016/how-to-install-a-package-that-contains-ubuntu-kernel-debug-symbols
# Ref        : https://wiki.ubuntu.com/DebuggingProgramCrash#Debug_Symbol_Packages

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

  Add Ubuntu DDEBS (debug symbol) repository and install kernel debug
  symbols, headers, gdb, and pkg-create-dbgsym for the running kernel.

  WARNING: Debug symbols are large (>680 MB). Prepare for a long download.

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

    local codename
    codename="$(lsb_release -cs)"
    local kernel_ver
    kernel_ver="$(uname -r)"

    section "Configuring Ubuntu DDEBS repository"
    printf 'deb http://ddebs.ubuntu.com %s main restricted universe multiverse\n' "$codename" | \
        _run tee /etc/apt/sources.list.d/ddebs.list >/dev/null
    printf 'deb http://ddebs.ubuntu.com %s-updates main restricted universe multiverse\n' "$codename" | \
        _run tee -a /etc/apt/sources.list.d/ddebs.list >/dev/null
    printf 'deb http://ddebs.ubuntu.com %s-proposed main restricted universe multiverse\n' "$codename" | \
        _run tee -a /etc/apt/sources.list.d/ddebs.list >/dev/null

    wget -O - http://ddebs.ubuntu.com/dbgsym-release-key.asc | _run apt-key add -
    _run apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ECDCAD72428D7C01
    _run apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C8CAB6595FDFF622

    section "Updating package lists"
    _run apt-get update

    section "Installing kernel image and headers for ${kernel_ver}"
    _run apt-get install -y \
        "linux-image-${kernel_ver}" \
        "linux-image-${kernel_ver}-dbgsym" \
        "linux-headers-${kernel_ver}"

    section "Installing GDB and dbgsym build tools"
    warn "Debug symbol package is large (>680 MB)..."
    _run apt-get install -y gdb
    _run apt-get install -y pkg-create-dbgsym

    section "Adding Debian debug repository"
    local sc_codename
    sc_codename="$(lsb_release -sc)"
    printf 'deb http://deb.debian.org/debian-debug/ %s-debug main\n' "$sc_codename" | \
        _run tee -a /etc/apt/sources.list.d/ddebs.list >/dev/null
    printf 'deb http://deb.debian.org/debian-debug/ %s-proposed-updates-debug main\n' "$sc_codename" | \
        _run tee -a /etc/apt/sources.list.d/ddebs.list >/dev/null

    ok "Kernel debug symbols installed for ${kernel_ver}."
    exit 0
}

main "$@"
