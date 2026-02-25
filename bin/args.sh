#!/usr/bin/env bash
# ==============================================================================
# args.sh — Demonstrates and prints shell positional argument variables
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
Usage: $PROGNAME [OPTIONS] ARG1 ARG2 ARG3

Prints the positional argument variables passed to the script.
Useful for understanding how shell positional parameters work.

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message

Arguments:
  ARG1  First positional argument  (\$1)
  ARG2  Second positional argument (\$2)
  ARG3  Third positional argument  (\$3)

Example:
  $PROGNAME hello world foo
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

    section "Positional Argument Inspection"
    info "Total argument passed is :- $#"
    info "\$# is  :- $#"
    info "\$@ is  :- $*"
    info "\$0 is  :- $0"
    info "\$1 is  :- ${1:-}"
    info "\$2 is  :- ${2:-}"
    info "\$3 is  :- ${3:-}"
}

main "$@"
