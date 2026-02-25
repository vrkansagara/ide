#!/usr/bin/env bash
# ==============================================================================
# default.sh — set default desktop configuration, display layout, and system settings
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
    printf 'Usage: %s [OPTIONS] [-a arg] [-d display]\n\n' "$PROGNAME"
    printf 'Set my default configuration for the working style.\n'
    printf 'Configures display layout, GNOME settings, audio, and brightness.\n\n'
    printf 'Options:\n'
    printf '  -a ARG           Set arg_1 argument\n'
    printf '  -d DISPLAY       Set display mode (2=dual-primary, 3=triple)\n'
    printf '  -v, --verbose    Enable verbose/debug output\n'
    printf '      --version    Print version and exit\n'
    printf '  -h, --help       Show this help message\n'
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

parse_args() {
    arg_1=""
    display=""
    while [ $# -gt 0 ]; do
        case "$1" in
            --verbose)     VERBOSE=1 ;;
            --version)     printf '%s version %s\n' "$PROGNAME" "$VERSION"; exit 0 ;;
            --help)        usage; exit 0 ;;
            -*)
                # Use getopts for -a and -d options
                local OPTIND=1
                while getopts ":a:d:vh" opt "$@"; do
                    case $opt in
                        a) arg_1="$OPTARG" ;;
                        d) display="$OPTARG" ;;
                        v) VERBOSE=1 ;;
                        h) usage; exit 0 ;;
                        \?) warn "Invalid option -${OPTARG}" ;;
                    esac
                    case "${OPTARG:-}" in
                        -*) warn "Option $opt needs a valid argument" ;;
                    esac
                done
                return
                ;;
        esac
        shift
    done
}

main() {
    # Use getopts directly for -a/-d style args
    arg_1=""
    display=""
    while getopts ":a:d:vh" opt; do
        case $opt in
            a) arg_1="$OPTARG" ;;
            d) display="$OPTARG" ;;
            v) VERBOSE=1 ;;
            h) usage; exit 0 ;;
            \?) warn "Invalid option -${OPTARG}" >&2; exit 1 ;;
        esac
        case "${OPTARG:-}" in
            -*) warn "Option $opt needs a valid argument"; exit 1 ;;
        esac
    done

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
    SCRIPT=$(readlink -f "")
    SCRIPTDIR=$(dirname "$SCRIPT")
    OS=$(uname -s)
    VER=$(uname -r)
    BUILD=$(uname -m)

    log "Started at ${CURRENT_DATE}"
    log "OS=${OS} VER=${VER} BUILD=${BUILD}"

    section "Installing packages"
    _run apt-get install alsa-utils neofetch arandr --yes --no-install-recommends

    section "INFORMATION"
    printf "Argument display is %s\n" "$display"
    printf "Argument arg_1 is %s\n" "$arg_1"
    section "INFORMATION"

    section "Configuring display layout"
    if [[ "$display" == 2 ]]; then
        info "Selecting primary display"
        if [ "$(lsb_release -sc)" == 'jammy' ]; then
            xrandr \
                --output XWAYLAND1 --mode 1366x768 --pos 1920x0 --rotate normal \
                --output XWAYLAND1 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
                --output XWAYLAND3 --off
        else
            xrandr \
                --output eDP-1 --mode 1366x768 --pos 1920x0 --rotate normal \
                --output HDMI-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
                --output DP-1 --off
        fi

    elif [[ "$display" == 3 ]]; then
        xrandr \
            --output eDP-1 --mode 1366x768 --pos 3286x0 --rotate normal \
            --output HDMI-1 --mode 1920x1080 --pos 1366x0 --rotate normal --primary \
            --output DP-1 --mode 1366x768 --pos 0x0 --rotate normal
    else
        info "Current screen setting."
        xrandr \
            --output eDP-1 --mode 1366x768 --pos 0x0 --rotate normal --primary \
            --output HDMI-1 --off \
            --output DP-1 --off
    fi

    # Check list of timezones which is available into system.
    # timedatectl list-timezones | grep -i Europ

    # Set default timeszone for the current system
    # _run timedatectl set-timezone Europe/Amsterdam
    section "Setting timezone and GNOME preferences"
    _run timedatectl set-timezone Asia/Kolkata

    # Enable secound into clock
    gsettings set org.gnome.desktop.interface clock-show-seconds true

    # Enable week number into calender
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    gsettings set org.gnome.desktop.calendar show-weekdate true

    # Enable hot corner
    gsettings set org.gnome.desktop.interface enable-hot-corners true

    # Show battery percentage
    gsettings set org.gnome.desktop.interface show-battery-percentage true

    # Disable cursor blinking
    gsettings set org.gnome.desktop.interface cursor-blink false

    # Disable laptop middle click to avoid unwanted pasting
    gsettings set org.gnome.desktop.interface gtk-enable-primary-paste false

    # Set Do not disturbe as ON ( By default )
    gsettings set org.gnome.desktop.notifications show-banners true

    # Set natural scrolling for touchpad and mouse
    gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
    gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true

    # Set right handed
    gsettings set org.gnome.desktop.peripherals.mouse left-handed false

    section "Configuring audio"
    # Set default volume to unmute with 45% audio
    # pactl list sinks short | awk '{print $2}'
    #speaker
    pactl set-default-sink alsa_output.usb-Jieli_Technology_UACDemoV1.0_1120022704060017-01.iec958-stereo
    # Headphon
    # pactl set-default-sink alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink

    pactl set-sink-mute @DEFAULT_SINK@ 0
    pactl set-sink-volume @DEFAULT_SINK@ 45%

    _run systemctl stop bluetooth

    section "Setting default brightness"
    # set default brightness
    "$HOME/.vim/bin/brightness.sh" set 15000

    ok "Default configuration applied."
}
main "$@"
