#!/usr/bin/env bash
# ==============================================================================
# battery.sh — Monitor battery level and notify on low/full charge
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
Usage: ${PROGNAME} [OPTIONS]

  Monitor battery level continuously and send desktop notifications when
  battery falls below 5% (low) or charges above 99% (full).

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message

Notes:
  Requires: acpi, powermgmt-base, libnotify-bin, notify-osd
  Checks every 300 seconds (5 minutes).
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

    if ! command -v acpi &>/dev/null; then
        info "Install acpi for better level check up"
        _run apt-get install --yes --no-install-recommends acpi powermgmt-base libnotify-bin notify-osd powermgmt-base
    fi

    while true; do
        export DISPLAY=:0.0
        battery_level=$(acpi -b | grep -P -o '[0-9]+(?=%)')

        info "Current battery level is $battery_level"

        #check if the battery level is lower then 10%
        if [ "$battery_level" -le 5 ]; then
            #       notify-send -u critical "Please plug your AC adapter" "Battery level: ${battery_level}% (lower then 5%)"
            notify-send -t 0 "Please plug your AC adapter" "Battery level: ${battery_level}% (lower then 5%)"
        fi

        #check if AC is plugged in
        if on_ac_power; then

            #check if the battery level is over 90%
            if [ "$battery_level" -ge 99 ]; then
                #           notify-send -u critical "Please unplug your AC adapter" "Battery level: ${battery_level}% (charged above 99%)" -i battery-full-charged
                notify-send -t 0 "Please unplug your AC adapter" "Battery level: ${battery_level}% (charged above 99%)" -i battery-full-charged
            fi

        fi

        #wait for 300 seconds (5 minute ) before checking again
        sleep 300
    done
}

main "$@"
