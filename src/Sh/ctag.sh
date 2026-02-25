#!/usr/bin/env bash
# ==============================================================================
# ctag.sh — Generate ctags for a PHP codebase directory
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
Usage: $PROGNAME [-v|--verbose] [--version] [-h|--help] [<directory> [<tagfile_name>]]

Description:
  Generates a ctags file for a directory of PHP source code using
  ctags-exuberant with PHP-specific options and common exclusions.

Options:
  -v, --verbose       Enable verbose/debug output
  --version           Print version and exit
  -h, --help          Show this help message and exit

Arguments:
  <directory>         Path to the PHP codebase directory
  <tagfile_name>      Name/alias for the generated tag file
                      (defaults to the basename of <directory>)

  If no arguments are given, the script will prompt interactively.
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
                # Positional args handled in main
                break
                ;;
        esac
        shift
    done
    REMAINING_ARGS=("$@")
}

main() {
    REMAINING_ARGS=()
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    local dir=""
    local name=""

    if [ "${#REMAINING_ARGS[@]}" -ge 2 ]; then
        # Two arguments: first is directory, second is "alias"
        dir="${REMAINING_ARGS[0]}"
        name="${REMAINING_ARGS[1]}"
    elif [ "${#REMAINING_ARGS[@]}" -eq 1 ]; then
        # One argument: use as directory, and use basename of directory as alias
        dir="${REMAINING_ARGS[0]}"
        name="$(basename "${REMAINING_ARGS[0]}")"
    else
        # Otherwise: prompt
        info "Enter the path to a directory containing PHP code you wish"
        info "to create tags for:"
        read -r dir
        info "Enter the name of the tagfile you wish to create:"
        read -r name
    fi

    info "Creating tags for directory '$dir' using alias '$name'"

    # Move to '$dir' is essential because ctags not accept the directory path

    cd "$dir"

    exec ctags-exuberant -f "$dir/$name" \
        --languages=PHP \
        -R \
        --totals=yes \
        --tag-relative=yes \
        --fields=+aimS \
        --extra=+f \
        --PHP-kinds=+cdfiv \
        --exclude="\.svn" \
        --exclude="\.git/" \
        --exclude="node_modules/" \
        --exclude="\DATA" \
        --exclude="\composer" \
        --exclude="\composer.phar" \
        --exclude='*.js' \
        --exclude='*.min.js' \
        --exclude='*.phtml' \
        --exclude='*.blade.php' \
        --regex-PHP='/(public |static |abstract |protected |private )+function ([^ (]*)/\/f/' \
        --regex-PHP='/abstract class ([^ ]*)/\/c/' \
        --regex-PHP='/interface ([^ ]*)/\/c/' \
        --regex-PHP='/get([a-z|A-Z|0-9]+)Attribute/\1/' \
        --regex-PHP='/scope([a-z|A-Z|0-9]+)/\1/'

    ok "ctag generation done."
}
main "$@"
