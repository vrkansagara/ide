#!/usr/bin/env bash
# ==============================================================================
# install.sh — System setup: install common Linux packages and tools
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

  Install common Linux development packages, Oh My Zsh, networking tools,
  optionally XFCE desktop, nginx, PHP, and configure system defaults.

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

    # https://unix.stackexchange.com/questions/175810/how-to-install-broadcom-bcm4360-on-debian-on-macbook-pro
    # _run apt-get install --no-install-recommends "linux-image-$(uname -r | sed 's,[^-]*-[^-]*-,,')" "linux-headers-$(uname -r | sed 's,[^-]*-[^-]*-,,')" broadcom-sta-dkms
    # _run modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
    # _run modprobe wl

    section "Configuring Ubuntu release upgrade policy"
    ## Ubuntu specific: Do not upgrade to latest release
    _run sed -i 's/Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades

    section "Installing system prerequisites"
    _run apt-get install --reinstall ca-certificates

    section "Installing application packages"
    info "Application related packages..."
    _run apt-get install -y git meld vim-gtk ack silversearcher-ag build-essential cmake vim-nox python3-dev markdown
    _run apt-get install -y git curl meld ack silversearcher-ag build-essential cmake make gcc libncurses5-dev libncursesw5-dev python3-dev markdown diodon fontconfig
    _run apt-get install -y libxml2-utils

    _run apt-get install -y zsh guake ufw geany httrack keepassxc cpulimit jq

    section "Fixing Guake libutempter dependency"
    _run apt-get install libutempter0

    section "Installing Node.js"
    info "Installing nodejs"
    curl -fsSL https://deb.nodesource.com/setup_14.x | _run bash -
    _run apt-get install -y nodejs

    section "Installing Oh My Zsh"
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    section "Installing network tools"
    info "Installing network related tools"
    # Use nmtui for wireless command line
    _run apt-get install -y iputils-ping net-tools lsof nmap whois network-manager wicd wicd-cli wicd-gtk wicd-curses

    section "Installing system tools"
    info "System related packages"
    _run apt-get install -y elinks htop exuberant-ctags curl lsb-release remmina

    section "Optional: XFCE desktop"
    local input
    read -r -p "Do you want to install XFCE desktop? [Y/n] " input
    case "$input" in
        [yY][eE][sS]|[yY])
            info "Installing desktop manager"
            _run apt-get install -y xfce4 xfce4-goodies
            _run apt-get install --reinstall thunar-volman gvfs-backends go-mtpfs mtp gmtp
            ;;
        [nN][oO]|[nN])
            info "Skipping XFCE..."
            ;;
        *)
            warn "Invalid input — skipping XFCE."
            ;;
    esac

    section "Installing web server and PHP"
    _run apt-get install -y nginx nginx-full php composer
    _run useradd "$USER" -g www-data 2>/dev/null || true
    _run chown -R "${USER}:www-data" "$HOME/htdocs" "$HOME/www" 2>/dev/null || true

    section "Cleaning up"
    _run apt-get autoremove

    section "Configuring system settings"
    # Adding current user to VirtualBox group
    _run adduser "$USER" vboxsf 2>/dev/null || true

    # GDM3 / LightDM configuration
    local current_user
    current_user="$(id -un)"
    printf 'AllowRoot=root\n' | _run tee -a /etc/gdm3/custom.conf >/dev/null
    printf 'AutomaticLogin=%s\n' "$current_user" | _run tee -a /etc/gdm3/custom.conf >/dev/null
    printf 'greeter-show-manual-login=true\n' | _run tee -a /etc/lightdm/lightdm.conf >/dev/null

    # Reset htop configuration
    _run rm -rf "$HOME/.config/htop/htoprc"

    ok "My required Linux binary installation is done."
    exit 0
}

main "$@"
