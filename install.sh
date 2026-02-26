#!/usr/bin/env bash
# ==============================================================================
# install.sh — Installation script for the vrkansagara IDE/VIM configuration
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

  Clone the vrkansagara IDE repository, back up any existing ~/.vim*
  configuration, install it, and set up symbolic links for dotfiles.

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

    local CURRENT_DATE
    CURRENT_DATE="$(date '+%Y%m%d%H%M%S')"

    # This directory name must not start with .vim
    local BACKUP_DIRECTORY="${HOME}/.old/vim-${CURRENT_DATE}"
    local CLONE_DIRECTORY="/tmp/.vim-${CURRENT_DATE}"

    section "Creating backup directory"
    if [ ! -d "$BACKUP_DIRECTORY" ]; then
        mkdir -p "$BACKUP_DIRECTORY"
    fi

    section "Cloning vrkansagara/ide vim configuration"
    info "Cloning the [vrkansagara/ide] vim configuration."
    git clone --recursive --branch master --depth 1 \
        https://github.com/vrkansagara/ide.git "${CLONE_DIRECTORY}"
    cd "${CLONE_DIRECTORY}"

    section "Backing up existing ~/.vim* configuration"
    info "Creating backup of ~/.vim* to ${BACKUP_DIRECTORY}"
    if [ "$(ls "${HOME}"/.vim* 2>/dev/null | wc -l)" != "0" ]; then
        info "Moving base vimrc config to backup folder"
        mv -f "${HOME}"/.vim* "$BACKUP_DIRECTORY" 2>/dev/null || true
    fi

    section "Installing vim configuration"
    # git pull --recurse-submodules
    # git submodule update --init --recursive
    mv "${CLONE_DIRECTORY}" "$HOME/.vim"
    mkdir -p "$HOME/.vim/pack/vendor/start/"

    rm -rf "$HOME/.vim/pack/"*
    sh -c "$HOME/.vim/submodule.sh"

    # echo "Set up pathogen for vim run time path."
    # mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

    section "Setting up symbolic links"
    info "Adding symbolic link for better git tracking of project"
    _run mv .zshrc .vimrc .bashrc /tmp 2>/dev/null || true
    _run mv "$HOME/.vim/coc-settings.dist.json" "$HOME/.vim/coc-settings.json" 2>/dev/null || true

    [ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.old" || true
    ln -P "$HOME/.vim/src/Dotfiles/zshrc" "$HOME/.zshrc"
    ln -P "$HOME/.vim/vimrc.vim" "$HOME/.vimrc"
    ln -P "$HOME/.vim/src/Dotfiles/bashrc" "$HOME/.bashrc"
    ln -P "$HOME/.vim/src/Sh/Git/hooks/pre-commit" "$HOME/.vim/.git/hooks"
    mkdir -p "$HOME/.vim/data/cache"

    section "Setting permissions"
    # Set sh and bin directory executable
    chmod -R +x "$HOME/.vim/src/Sh/"* "$HOME/.vim/bin"

    # Before leaving the script, reset to home directory
    cd "$HOME"

    ok "Installed the Ultimate Vim configuration of [vrkansagara] successfully! Enjoy :-)"
    exit 0
}

main "$@"
