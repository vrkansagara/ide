#!/usr/bin/env bash
# ==============================================================================
# vim.sh — Install Vim from PPA or compile from source
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

  Install Vim from the jonathonf PPA (quick install), or compile from source
  for a fully customised build with Python, Ruby, Lua, and Perl support.

Options:
  --from-source   Compile Vim from source instead of using the PPA
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message
EOF
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

parse_args() {
    FROM_SOURCE=0
    while [ $# -gt 0 ]; do
        case "$1" in
            --from-source)
                FROM_SOURCE=1
                shift
                ;;
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

install_from_ppa() {
    section "Adding jonathonf/vim PPA"
    _run add-apt-repository ppa:jonathonf/vim
    _run apt update

    section "Installing Vim from PPA"
    _run apt install --yes --no-install-recommends vim vim-gtk3
}

install_from_source() {
    local apt_package_target="vim-gtk"
    local tmp_dir="$HOME/tmp/latest"

    section "Removing existing Vim packages"
    _run apt-get purge "${apt_package_target}"
    _run apt-get build-dep "${apt_package_target}"

    section "Cloning Vim source"
    mkdir -p "${tmp_dir}"
    git clone https://github.com/vim/vim.git --depth 1 -b master "${tmp_dir}"
    cd "${tmp_dir}/vim"
    git stash
    git reset --hard HEAD
    git clean -fd

    section "Configuring Vim build"
    _run make distclean
    ./configure \
        --disable-acl \
        --disable-darwin \
        --disable-gpm \
        --disable-gtk2-check \
        --disable-gtktest \
        --disable-gui \
        --disable-largefile \
        --disable-netbeans \
        --disable-option-checking \
        --disable-selinux \
        --disable-sniff \
        --disable-sysmouse \
        --disable-workshop \
        --disable-xim \
        --disable-xsmp \
        --enable-cscope \
        --enable-fontset \
        --enable-multibyte \
        --enable-perlinterp \
        --enable-luainterp \
        --enable-python3interp=yes \
        --enable-pythoninterp=yes \
        --enable-rubyinterp=yes \
        --enable-fail-if-missing \
        --with-features=normal \
        --enable-gui=auto \
        --enable-gui=gtk2 \
        --with-x \
        --with-compiledby="vallabhdas kansagara <vrkansagara@gmail.com>" \
        --with-vim-name=vi \
        --with-features=huge \
        --prefix=/usr

    section "Building and installing Vim"
    make
    _run rm -rf /usr/local/bin/vim /usr/share/vim/
    _run make install
}

main() {
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    if [ "$FROM_SOURCE" -eq 1 ]; then
        install_from_source
    else
        install_from_ppa
    fi

    ok "Vim installation complete."
    exit 0
}

main "$@"
