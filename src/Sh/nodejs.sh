#!/usr/bin/env bash
# ==============================================================================
# nodejs.sh — Safe NVM / Node.js installation and dependency update helper
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
#
# Description: Safe node / nvm helper for installing nvm, node, and
#              running npm updates in a low-RAM, low-CPU friendly way.

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
Usage: ${PROGNAME} [OPTIONS] MODE

  Install NVM, Node.js, or update project dependencies.

Modes (at least one required):
  --nvm           Install NVM (idempotent, safe)
  --nodejs        Install Node.js via NVM (LTS + latest)
  --node-latest   Update project dependencies safely

Options:
  -v, --verbose   Enable verbose/debug output (set -x)
  --version       Print version and exit
  -h, --help      Show this help message
EOF
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

# ---------------------------
# Globals
# ---------------------------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
NICE_CMD="$(command -v nice || true)"
IONICE_CMD="$(command -v ionice || true)"

# ---------------------------
# Helper
# ---------------------------
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ---------------------------
# Download helper
# ---------------------------
download_with_retries() {
    local url="$1" dest="$2" tries="${3:-3}" wait="${4:-3}"

    local attempt
    for attempt in $(seq 1 "$tries"); do
        if command_exists curl; then
            curl -fsSL --connect-timeout 10 "$url" -o "$dest" && return 0
        elif command_exists wget; then
            wget -qO "$dest" "$url" && return 0
        fi
        sleep "$wait"
    done

    fatal "Download failed: $url"
}

# ---------------------------
# NVM Install
# ---------------------------
nvmInstall() {
    if [[ "$(id -u)" -eq 0 ]]; then
        fatal "Do not install NVM as root."
    fi

    if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
        # shellcheck source=/dev/null
        . "$HOME/.nvm/nvm.sh"
        ok "NVM already installed."
        return 0
    fi

    local tmp=""
    trap '[[ -n "$tmp" ]] && rm -f "$tmp"' EXIT

    tmp="$(mktemp -t nvm-install-XXXX.sh)"

    download_with_retries \
        "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh" \
        "$tmp" 5 4

    bash "$tmp"

    if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
        # shellcheck source=/dev/null
        . "$HOME/.nvm/nvm.sh"
        ok "NVM installed successfully."
    else
        fatal "NVM install failed."
    fi
}

# ---------------------------
# Node Install
# ---------------------------
nodejsInstall() {
    if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
        # shellcheck source=/dev/null
        . "$HOME/.nvm/nvm.sh"
    else
        fatal "NVM not loaded. Run --nvm first."
    fi

    info "Installing Node LTS..."
    nice -n 10 nvm install --lts || true
    nvm use --lts

    info "Installing latest stable Node..."
    nice -n 10 nvm install node || true

    ok "Installed Node versions:"
    nvm ls
}

# ---------------------------
# Update Project Dependencies
# ---------------------------
nodeLatest() {
    if ! command_exists npm; then
        fatal "npm not found."
    fi

    local run_cmd="npm install --no-audit --no-fund --silent"
    [[ -f package-lock.json ]] && run_cmd="npm ci --no-audit --no-fund --silent"

    info "Running dependency install..."
    if [[ -n "$IONICE_CMD" && -n "$NICE_CMD" ]]; then
        # shellcheck disable=SC2086
        nice -n 10 ionice -c 2 $run_cmd
    else
        # shellcheck disable=SC2086
        nice -n 10 $run_cmd
    fi

    if command_exists npx; then
        info "Updating package.json versions (ncu)..."
        npx -y npm-check-updates -u --silent || true
        npm update --silent || true
    fi

    if [[ -d node_modules/.bin ]]; then
        find node_modules/.bin -type f -exec chmod u+x {} \; || true
    fi

    ok "Node dependencies updated."
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

main() {
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    if [[ "$#" -eq 0 ]]; then
        usage
        exit 0
    fi

    while [[ "${1:-}" ]]; do
        case "$1" in
            --nvm)         nvmInstall ;;
            --nodejs)      nodejsInstall ;;
            --node-latest) nodeLatest ;;
            --help|-h)     usage; exit 0 ;;
            *)             fatal "Unknown option: $1" ;;
        esac
        shift
    done

    exit 0
}

main "$@"
