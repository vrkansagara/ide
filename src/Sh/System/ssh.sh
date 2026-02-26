#!/usr/bin/env bash
# ==============================================================================
# ssh.sh — Automated SSH safe setup with correct permissions
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

  Install keychain, configure ~/.ssh/config, apply correct SSH directory
  permissions, start ssh-agent if not running, add SSH keys, and configure
  GPG agent.

  Notes:
    - UseKeychain (macOS only) is not set here
    - For MySQL via SSH tunnel: ssh-keygen -p -m PEM -f

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

    section "Installing keychain"
    export DEBIAN_FRONTEND=noninteractive
    _run apt-get update -qq
    _run apt-get install -y --no-install-recommends keychain

    info "${USER} is the only one owning ${HOME}/.ssh directory"

    section "Ensuring ~/.ssh directory"
    mkdir -p "$HOME/.ssh"

    section "Configuring ~/.ssh/config"
    local SSH_CONFIG="$HOME/.ssh/config"
    printf '%s\n' "Host *
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_rsa
    IdentityFile ~/.ssh/id_rsa_vrkansagara
" | _run tee -a "$SSH_CONFIG" >/dev/null

    _run chown "${USER}:${USER}" "$SSH_CONFIG"
    _run chmod 600 "$SSH_CONFIG"

    section "Applying SSH golden permissions"
    _run chmod 700 "$HOME/.ssh"

    # Private keys
    local key
    for key in "$HOME/.ssh"/id_*; do
        if [[ -f "$key" && ! "$key" =~ \.pub$ ]]; then
            _run chmod 600 "$key"
        fi
    done

    # Public keys must remain world-readable
    local pub
    for pub in "$HOME/.ssh"/*.pub; do
        [[ -f "$pub" ]] && _run chmod 644 "$pub"
    done

    section "Starting ssh-agent"
    if ! pgrep -u "$USER" ssh-agent >/dev/null 2>&1; then
        eval "$(ssh-agent -s)"
    fi

    # Add keys if they exist
    [[ -f "$HOME/.ssh/id_rsa" ]] && ssh-add "$HOME/.ssh/id_rsa"
    [[ -f "$HOME/.ssh/id_rsa_vrkansagara" ]] && ssh-add "$HOME/.ssh/id_rsa_vrkansagara"

    section "Configuring GPG"
    _run chown -R "${USER}:${USER}" "$HOME/.gnupg"
    _run chmod 700 "$HOME/.gnupg"
    _run chmod 600 "$HOME/.gnupg"/*
    if [ -f "$HOME/.ssh/gnupg/vrkansagara-sec.key" ]; then
        gpg --import "$HOME/.ssh/gnupg/vrkansagara-sec.key"
    fi
    gpgconf --kill gpg-agent
    gpgconf --launch gpg-agent
    gpg --list-keys

    ok "Linux ${HOME}/.ssh directory permission applied safely."
    exit 0
}

main "$@"
