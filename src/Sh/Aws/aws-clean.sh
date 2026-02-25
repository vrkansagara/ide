#!/usr/bin/env bash
# ==============================================================================
# aws-clean.sh — Clean AWS account resources (S3 buckets, etc.)
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
Usage: ${PROGNAME} [OPTIONS] --s3 <aws-profile>

  Clean AWS account resources such as S3 buckets for a given AWS CLI profile.

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message

Examples:
  ${PROGNAME} --s3 my-profile
  ${PROGNAME} -v --s3 my-profile
EOF
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :- lets clean aws account resource(s)
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

cleanS3() {
    info "Available s3 bucket(s)"
    aws s3 ls --profile "$1"
    warn "Removing all s3 bucket(s)"
    aws s3 ls --profile "$1" | awk '{print $3}' | xargs -I {} sh -c "aws s3 rb --force s3://{} --profile $1"
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
            --s3)
                S3_PROFILE="${2:-}"
                [ -z "$S3_PROFILE" ] && fatal "--s3 requires an AWS profile name argument"
                shift 2
                ;;
            *)
                fatal "Unknown option: $1"
                ;;
        esac
    done
}

main() {
    export DEBIAN_FRONTEND=noninteractive
    export CURRENT_DATE
    CURRENT_DATE="$(date "+%Y%m%d%H%M%S")"

    shopt -s extglob

    S3_PROFILE=""
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    info "Script started at ${CURRENT_DATE}"

    if [ -n "$S3_PROFILE" ]; then
        cleanS3 "$S3_PROFILE"
    fi

    ok "Script end at $(date "+%Y%m%d%H%M%S")"
}

main "$@"
