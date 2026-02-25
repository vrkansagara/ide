#!/usr/bin/env bash
# ==============================================================================
# clear_cache_MS_Teams.sh — clear all cache for Microsoft Teams on Linux/Mac
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

# This script cleans all cache for Microsoft Teams on Linux
# Tested on Ubuntu-like, Debian by @necrifede and Arch Linux by @lucas-dclrcq. Feel free to test/use in other distributions.
# Tested with Teams via snap package.
#
# How to use in terminal:
# ./clear_cache_MS_Teams.sh ( deb-stable | deb-insider | snap )
# or
# bash clear_cache_MS_Teams.sh ( deb-stable | deb-insider | snap )

# Variable process name is defined on case statement.

usage() {
    printf 'Usage: %s [OPTIONS] ( deb-stable | deb-insider | snap | mac )\n\n' "$PROGNAME"
    printf 'Clear all cache for Microsoft Teams on Linux/Mac.\n\n'
    printf 'Options:\n'
    printf '  -v, --verbose    Enable verbose/debug output\n'
    printf '      --version    Print version and exit\n'
    printf '  -h, --help       Show this help message\n'
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

parse_args() {
    TEAMS_ARG=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose)  VERBOSE=1 ;;
            --version)     printf '%s version %s\n' "$PROGNAME" "$VERSION"; exit 0 ;;
            -h|--help)     usage; exit 0 ;;
            -*)            fatal "Unknown option: $1" ;;
            *)             TEAMS_ARG="$1" ;;
        esac
        shift
    done
}

main() {
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    if [ -z "$TEAMS_ARG" ]; then
        info "Script requires argument. (ex. deb-stable | deb-insider | snap | mac)"
        usage
        exit 1
    fi

    TEAMS_PROCESS_NAME=""

    case "$TEAMS_ARG" in
        deb-stable)
            TEAMS_PROCESS_NAME=teams
            cd "$HOME/.config/Microsoft/Microsoft Teams" || exit 1
            ;;
        deb-insider)
            TEAMS_PROCESS_NAME=teams-insiders
            cd "$HOME/.config/Microsoft/Microsoft Teams - Insiders" || exit 1
            ;;
        snap)
            TEAMS_PROCESS_NAME=teams
            cd "$HOME/snap/teams/current/.config/Microsoft/Microsoft Teams" || exit 1
            ;;
        mac)
            TEAMS_PROCESS_NAME=teams
            rm -rf ~/Library/Application\ Support/Microsoft
            #    cd "$HOME/snap/teams/current/.config/Microsoft/Microsoft Teams" || exit 1
            exit 0
            ;;
        *)
            warn "Use $PROGNAME ( deb-stable | deb-insider | snap ) as parameter."
            exit 1
            ;;
    esac

    section "Clearing Microsoft Teams cache"

    # Test if Microsoft Teams is running
    if [ "$(pgrep "${TEAMS_PROCESS_NAME}" | wc -l)" -gt 1 ]; then
        rm -rf "Application Cache/Cache/"*
        rm -rf blob_storage/*
        rm -rf Cache/* # Main cache
        rm -rf "Code Cache/js/"*
        rm -rf databases/*
        rm -rf GPUCache/*
        rm -rf IndexedDB/*
        rm -rf "Local Storage/"*
        #rm -rf backgrounds/* # Background function presents on Teams for Windows only.
        find ./ -maxdepth 1 -type f -name "*log*" -exec rm {} \;
        sleep 5
        killall "${TEAMS_PROCESS_NAME}"
        # After this, MS Teams will open again.
        ok "Microsoft Teams cache cleared and process killed."
    else
        warn "Microsoft Teams is not running."
        exit 0
    fi
}
main "$@"
