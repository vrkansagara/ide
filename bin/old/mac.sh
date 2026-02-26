#!/usr/bin/env bash
# ==============================================================================
# mac.sh — macOS helper: home permissions, Homebrew, and cache flush
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0

set -o errexit
set -o pipefail
set -o nounset

shopt -s extglob

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

  macOS helper script for home directory permissions, Homebrew management,
  and asset cache flushing.

Modes:
  --home-permission   Reset home directory permissions (macOS)
  --brew              Install or update Homebrew
  --flush             Flush macOS asset caches

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message
EOF
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

home_permission_mac() {
    section "Resetting home directory permissions"
    chflags -R nouchg "$HOME"
    diskutil resetUserPermissions / "$(id -u)"
}

do_brew() {
    section "Homebrew"
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        info "Updating Homebrew..."
        brew update
        brew doctor
    fi
}

do_flush() {
    section "Flushing macOS caches"
    info "AssetCacheManagerUtil commands reference:"
    info "  settings  — Display content cache settings"
    info "  status    — Display content cache status"
    info "  canActivate / isActivated — Check content caching state"
    info "  flushCache / flushPersonalCache / flushSharedCache — Remove cached content"

    _run AssetCacheManagerUtil flushCache
    _run AssetCacheManagerUtil flushPersonalCache
    _run AssetCacheManagerUtil flushSharedCache
    _run AssetCacheManagerUtil reloadSettings

    _run dscacheutil -flushcache
    _run killall -HUP mDNSResponder

    # Drop memory caches
    sync && _run purge
    _run du -sh /Library/Caches/* | sort -h

    # https://support.apple.com/en-in/guide/deployment/depfaba5bc52/web
    AssetCacheManagerUtil settings
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

    local current_date
    current_date="$(date '+%Y%m%d%H%M%S')"
    log "Started at ${current_date}"

    if [[ "${1:-}" == "--home-permission" ]]; then
        home_permission_mac
    elif [[ "${1:-}" == "--brew" ]]; then
        do_brew
    elif [[ "${1:-}" == "--flush" ]]; then
        do_flush
    else
        usage
        exit 1
    fi

    ok "mac.sh operation complete."
    exit 0
}

main "$@"
