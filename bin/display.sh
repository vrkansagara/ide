#!/usr/bin/env bash
# ==============================================================================
# default.sh — set default desktop configuration, display layout, and system settings
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0

set -o errexit
set -o pipefail
set -o nounset

shopt -s extglob

# ------------------------------------------------------------------------------
# Constants + state
# ------------------------------------------------------------------------------
readonly VERSION="2.0.0"
readonly PROGNAME="${0##*/}"
VERBOSE=0
SUDO_CMD=""
arg_1=""
display=""

# ------------------------------------------------------------------------------
# Monitor identifiers — edit these to match your hardware
# ------------------------------------------------------------------------------
MON_LAPTOP="eDP-1"          # built-in laptop screen (right-most)
MON_CENTER="HDMI-1"         # external center monitor (primary when present)
MON_LEFT="DP-1"             # external left monitor

# Resolutions
RES_LAPTOP="1366x768"
RES_CENTER="1920x1080"
RES_LEFT="1366x768"

# ------------------------------------------------------------------------------
# Color block
# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
# Logging helpers
# ------------------------------------------------------------------------------
info()    { printf '%b[INFO]  %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
warn()    { printf '%b[WARN]  %s%b\n' "$C_YELLOW" "$*" "$C_RESET"; }
fatal()   { printf '%b[FATAL] %s%b\n' "$C_RED"    "$*" "$C_RESET" >&2; exit 1; }
ok()      { printf '%b[OK]    %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
log()     { [ "$VERBOSE" -ne 0 ] && printf '[DEBUG] %s\n' "$*" || true; }
section() { printf '\n%b=== %s ===%b\n' "${C_BOLD}${C_CYAN}" "$*" "$C_RESET"; }

# ------------------------------------------------------------------------------
# Usage
# ------------------------------------------------------------------------------
usage() {
    cat <<EOF
Usage: $PROGNAME [OPTIONS]

Set my default configuration for the working style.
Auto-detects connected monitors and applies the correct xrandr layout:

  Laptop only         → eDP-1 primary
  Laptop + HDMI-1     → HDMI-1 primary (left), eDP-1 right
  DP-1 + HDMI-1 + eDP-1 → DP-1 left, HDMI-1 middle+primary, eDP-1 right

Options:
  -a ARG           Set arg_1 argument
  -v, --verbose    Enable verbose/debug output
      --version    Print version and exit
  -h, --help       Show this help message

Example:
  $PROGNAME
  $PROGNAME --verbose
EOF
}

# ------------------------------------------------------------------------------
# Sudo wrapper
# ------------------------------------------------------------------------------
_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

# ------------------------------------------------------------------------------
# Argument parsing
# ------------------------------------------------------------------------------
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose) VERBOSE=1; set -x; shift ;;
            --version)    printf '%s v%s\n' "$PROGNAME" "$VERSION"; exit 0 ;;
            -h|--help)    usage; exit 0 ;;
            -a)           [ -n "${2:-}" ] || fatal "-a requires an argument"; arg_1="$2"; shift 2 ;;
            --)           shift; break ;;
            -*)           fatal "Unknown option: '$1'. Use -h for help." ;;
            *)            break ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# Detect which monitors are currently connected via xrandr
# Returns 0 if connected, 1 if not
# ------------------------------------------------------------------------------
_monitor_connected() {
    xrandr --query | grep -q "^${1} connected"
}

# ------------------------------------------------------------------------------
# Apply xrandr display layout based on connected monitors
# Layout priority:
#   DP-1 + HDMI-1 + eDP-1  →  DP-1(left) | HDMI-1(center,primary) | eDP-1(right)
#   HDMI-1 + eDP-1          →  HDMI-1(primary) | eDP-1(right)
#   eDP-1 only              →  eDP-1(primary)
# ------------------------------------------------------------------------------
configure_display() {
    local has_laptop=0 has_center=0 has_left=0

    _monitor_connected "$MON_LAPTOP" && has_laptop=1
    _monitor_connected "$MON_CENTER" && has_center=1
    _monitor_connected "$MON_LEFT"   && has_left=1

    info "Detected monitors — ${MON_LEFT}:${has_left}  ${MON_CENTER}:${has_center}  ${MON_LAPTOP}:${has_laptop}"

    if [ "$has_left" -eq 1 ] && [ "$has_center" -eq 1 ] && [ "$has_laptop" -eq 1 ]; then
        # ── Triple monitor ──────────────────────────────────────────────────
        # DP-1(0) | HDMI-1(1366) | eDP-1(3286)  [1366+1920=3286]
        section "Triple display: ${MON_LEFT} | ${MON_CENTER}(primary) | ${MON_LAPTOP}"
        xrandr \
            --output "$MON_LEFT"   --mode "$RES_LEFT"   --pos 0x0     --rotate normal \
            --output "$MON_CENTER" --mode "$RES_CENTER" --pos 1366x0  --rotate normal --primary \
            --output "$MON_LAPTOP" --mode "$RES_LAPTOP" --pos 3286x0  --rotate normal

    elif [ "$has_center" -eq 1 ] && [ "$has_laptop" -eq 1 ]; then
        # ── Dual: HDMI + laptop ──────────────────────────────────────────────
        # HDMI-1(0,primary) | eDP-1(1920)
        section "Dual display: ${MON_CENTER}(primary) | ${MON_LAPTOP}"
        xrandr \
            --output "$MON_CENTER" --mode "$RES_CENTER" --pos 0x0    --rotate normal --primary \
            --output "$MON_LAPTOP" --mode "$RES_LAPTOP" --pos 1920x0 --rotate normal \
            --output "$MON_LEFT"   --off

    elif [ "$has_center" -eq 1 ]; then
        # ── Only center monitor (laptop lid closed) ──────────────────────────
        section "Single display: ${MON_CENTER}(primary)"
        xrandr \
            --output "$MON_CENTER" --mode "$RES_CENTER" --pos 0x0 --rotate normal --primary \
            --output "$MON_LAPTOP" --off \
            --output "$MON_LEFT"   --off

    else
        # ── Laptop only ──────────────────────────────────────────────────────
        section "Laptop only: ${MON_LAPTOP}(primary)"
        xrandr \
            --output "$MON_LAPTOP" --mode 1920x1080 --pos 0x0 --rotate normal --primary \
            --output "$MON_CENTER" --off \
            --output "$MON_LEFT"   --off
    fi

    ok "Display layout applied."
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
    SCRIPT=$(readlink -f "$0")
    SCRIPTDIR=$(dirname "$SCRIPT")
    OS=$(uname -s)
    VER=$(uname -r)
    BUILD=$(uname -m)

    log "Started at ${CURRENT_DATE}"
    log "Script dir: ${SCRIPTDIR}"
    log "OS=${OS} VER=${VER} BUILD=${BUILD}"

    section "Installing packages"
    _run apt-get install alsa-utils arandr --yes --no-install-recommends

    section "INFORMATION"
    printf "Argument display is %s\n" "$display"
    printf "Argument arg_1 is %s\n" "$arg_1"

    section "Configuring display layout (auto-detect)"
    configure_display

    # Check list of timezones which is available into system.
    # timedatectl list-timezones | grep -i Europ

    # Set default timeszone for the current system
    # _run timedatectl set-timezone Europe/Amsterdam
    section "Setting timezone and GNOME preferences"
    _run timedatectl set-timezone Asia/Kolkata

    _run systemctl stop bluetooth

    ok "Default configuration applied."
}
main "$@"
