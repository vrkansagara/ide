#!/usr/bin/env bash
# ==============================================================================
# sound.sh — Switch audio output between HDMI, digital, and analog sinks
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
#
# Usage: audioswitch; audioswitch 1; audioswitch 2; audioswitch 3; audioswitch 4

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
Usage: ${PROGNAME} [OPTIONS] [CHOICE]

  Switch audio output sink via PulseAudio.
  CHOICE can be 1-4 or 5 (exit):
    1 = LG ULTRAWIDE  (HDMI, CARD_1_PROFILE_1)
    2 = LG TV         (HDMI, CARD_1_PROFILE_2)
    3 = Digital Output (built-in, CARD_0_PROFILE_1)
    4 = Headphones    (built-in, CARD_0_PROFILE_2)
    5 = Exit

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
                break
                ;;
        esac
    done
}

readonly CARD_1="pci-0000_03_00.1"             # HDMI Audio Controller of NVidia GTX 660
readonly CARD_1_PROFILE_1="hdmi-stereo"        # LG ULTRAWIDE
readonly CARD_1_PROFILE_2="hdmi-stereo-extra1" # LG TV
readonly CARD_0="pci-0000_00_1b.0"             # Built-in Audio
readonly CARD_0_PROFILE_1="iec958-stereo"      # Digital Output
readonly CARD_0_PROFILE_2="analog-stereo"      # Headphones

choose_sink() {
    local choice="$1"
    local card prof

    if [ "$choice" = "1" ]; then
        card="$CARD_1"
        prof="$CARD_1_PROFILE_1"
    elif [ "$choice" = "2" ]; then
        card="$CARD_1"
        prof="$CARD_1_PROFILE_2"
    elif [ "$choice" = "3" ]; then
        card="$CARD_0"
        prof="$CARD_0_PROFILE_1"
    elif [ "$choice" = "4" ]; then
        card="$CARD_0"
        prof="$CARD_0_PROFILE_2"
    elif [ "$choice" = "5" ]; then
        info "Exiting."
        exit 0
    else
        printf '\nYou should choose between:\n'
        printf '\n\t[1] LG ULTRAWIDE\n\t[2] LG TV\n\t[3] Digital Output\n\t[4] Headphones\n\t[5] Exit\n\n'
        printf 'Your choice: '
        read -r choice
        printf '\n'
        choose_sink "$choice"
        return
    fi

    info "Switching to card=${card} profile=${prof}"
    pactl set-card-profile "alsa_card.${card}" "output:${prof}"
    pacmd set-default-sink "alsa_output.${card}.${prof}" &>/dev/null

    # Redirect existing inputs to the new sink
    local i
    for i in $(pacmd list-sink-inputs | grep index | awk '{print $2}'); do
        pacmd move-sink-input "$i" "alsa_output.${card}.${prof}" &>/dev/null
    done

    ok "Audio switched to profile: ${prof}"
}

main() {
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    local choice="${1:-}"
    choose_sink "$choice"
    exit 0
}

main "$@"
