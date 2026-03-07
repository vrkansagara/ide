#!/usr/bin/env bash
# ==============================================================================
# docker.sh — Install Docker CE and Docker Compose on Ubuntu
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0

set -o errexit
set -o pipefail
set -o nounset

readonly SCRIPT_VERSION="2.0.0"
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
Usage: $PROGNAME [-v|--verbose] [--version] [-h|--help]

Description:
  Removes legacy Docker packages, installs Docker CE from the official
  repository, sets up Docker Compose, configures user permissions, and
  verifies the installation with a hello-world container.

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message and exit
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
                printf '%s version %s\n' "$PROGNAME" "$SCRIPT_VERSION"
                exit 0
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            *)
                warn "Unknown argument: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done
}

main() {
    [ $# -eq 0 ] && { usage; exit 0; }
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    info "Lets remove Docker related stuff..."
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        _run apt-get remove "$pkg" || true
    done

    info "Docker related permission..."
    # Add Docker's official GPG key:
    _run apt-get update
    _run apt-get install ca-certificates curl
    _run install -m 0755 -d /etc/apt/keyrings
    DISTRO_ID="$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')"
    _run curl -fsSL "https://download.docker.com/linux/${DISTRO_ID}/gpg" -o /etc/apt/keyrings/docker.asc
    _run chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    DISTRO_CODENAME="$(grep -oP '(?<=^VERSION_CODENAME=).+' /etc/os-release | tr -d '"')"
    DISTRO_ID="$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${DISTRO_ID} ${DISTRO_CODENAME} stable" |
        _run tee /etc/apt/sources.list.d/docker.list >/dev/null
    _run apt-get update

    _run apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    if [ ! -f "/usr/bin/docker-compose" ]; then
        _run curl -L "https://github.com/docker/compose/releases/download/1.28.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        _run chmod +x /usr/local/bin/docker-compose
        _run ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi

    if [ -f "/usr/bin/docker" ]; then
        _run chmod 666 /var/run/docker.sock

        if grep -q docker /etc/group; then
            info "Group docker"
        else
            _run groupadd docker
        fi

        if getent group docker | grep -qw "${USER}"; then
            info "User [ ${USER} ] is into docker group"
        else
            _run usermod -aG docker "${USER}"
            if [ -d "$HOME/$USER/.docker" ]; then
                _run chown "$USER":"$USER" /home/"$USER"/.docker -R
                _run chmod g+rwx "$HOME/.docker" -R
            fi
        fi
    fi

    #_run sysctl -w vm.max_map_count=262144
    _run systemctl restart docker
    docker run hello-world
    ok "Docker compose script"

    # curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    # DRY_RUN=1 sh /tmp/get-docker.sh
}
main "$@"
