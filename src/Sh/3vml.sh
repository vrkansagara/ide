#!/usr/bin/env bash
# ==============================================================================
# 3vml.sh — Run PHP code through all available PHP binaries (3v4l.org style)
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# Note       : https://3v4l.org/about

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
Usage: $PROGNAME [-v|--verbose] [--version] [-h|--help] <input_id>

Description:
  Runs a PHP input file through all available PHP binaries, storing output
  under /out/<input_id>/. This replicates the original 3v4l.org shell logic.

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message and exit

Arguments:
  <input_id>      The ID of the input file located at /in/<input_id>
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
                # Remaining argument is the input_id
                INPUT_ID="$1"
                ;;
        esac
        shift
    done
}

# When I started in 2012, this site was nothing more than a small bash script that looped through all
# available PHP binaries and stored the output in /out/. For fun; here is the source-code of the
# script that I started with:

main() {
    INPUT_ID=""
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    if [ -z "$INPUT_ID" ]; then
        fatal "No input_id provided. Use -h for help."
    fi

    ulimit -f 64 -m 64 -t 2 -u 128

    [[ ! -d "/out/${INPUT_ID}/" ]] && mkdir "/out/${INPUT_ID}/" || chmod u+w "/out/${INPUT_ID}/"

    for bin in /bin/php-*; do
        info "$bin - $INPUT_ID"
        nice -n 15 sudo -u nobody "$bin" -c /etc/ -q "/in/${INPUT_ID}" >"/out/${INPUT_ID}/${bin##*-}" 2>&1 &
        PID=$!
        (
            sleep 3.1
            kill -9 "$PID" 2>/dev/null
        ) &
        wait "$PID" || true
        ex=$?

        sf="/out/${INPUT_ID}/${bin##*-}-exit"
        [[ $ex -eq 0 && -f "$sf" ]] && rm "$sf" || true
        [[ $ex -ne 0 ]] && printf '%s' "$ex" >"$sf" || true
    done

    chmod u-w "/out/${INPUT_ID}/"
}
main "$@"
