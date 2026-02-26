#!/usr/bin/env bash
# ==============================================================================
# git-rewrite.sh — Safely rewrite commit author email or re-sign commits
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
#
# Purpose    : Rewrite git history to fix commit email or add GPG signatures
#
# GPG key import (vrkansagara):
#   curl -sL https://gist.githubusercontent.com/vrkansagara/862e1ea96091ddf01d8e3f0786eefae8/raw/bcc458eb4b2c0eb441aaf7a56f385bc6cd4cb25a/vrkansagara.gpg | gpg --import
#   export GPGKEY=8BA6E7ABD8112B3E

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
Usage: ${PROGNAME} [OPTIONS] COMMAND

  Rewrite git commit history to fix author/committer email or re-sign
  commits with GPG. Must be run from inside a git repository.

Commands:
  email    Rewrite author/committer email in all commits
  sign     Re-sign commits belonging to your email with GPG

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message

Examples:
  ${PROGNAME} email
  ${PROGNAME} sign
  ${PROGNAME} -v email
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
                break
                ;;
        esac
    done
}

update_email() {
    local OLD_EMAIL="vallabh@vrkansagara.local"
    local CORRECT_EMAIL="vrkansagara@gmail.com"
    local CORRECT_NAME="Vallabhdas Kansagara"

    info "Rewriting author/committer email..."

    git filter-branch --force --env-filter "
if [[ \"\$GIT_COMMITTER_EMAIL\" == \"${OLD_EMAIL}\" ]]; then
    export GIT_COMMITTER_NAME=\"${CORRECT_NAME}\";
    export GIT_COMMITTER_EMAIL=\"${CORRECT_EMAIL}\";
fi
if [[ \"\$GIT_AUTHOR_EMAIL\" == \"${OLD_EMAIL}\" ]]; then
    export GIT_AUTHOR_NAME=\"${CORRECT_NAME}\";
    export GIT_AUTHOR_EMAIL=\"${CORRECT_EMAIL}\";
fi
" --tag-name-filter cat -- --branches --tags
}

update_signature() {
    local GPG_EMAIL="vrkansagara@gmail.com"

    warn "Rewriting history with signed commits (only yours)..."
    warn "WARNING: This rewrites ALL history. Ensure backup or fresh clone."

    git filter-branch --force --commit-filter '
if [ "$GIT_AUTHOR_EMAIL" = "'"${GPG_EMAIL}"'" ]; then
    git commit-tree -S "$@"
else
    git commit-tree "$@"
fi
' --tag-name-filter cat -- --branches --tags
}

main() {
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    # Ensure we are inside a git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        fatal "Not inside a git repository. Aborting."
    fi

    export FILTER_BRANCH_SQUELCH_WARNING=1

    local cmd="${1:-}"

    case "$cmd" in
        email)
            section "Rewriting commit email"
            update_email
            ;;
        sign)
            section "Re-signing commits with GPG"
            update_signature
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    ok "Done."
    exit 0
}

main "$@"
