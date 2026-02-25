#!/usr/bin/env bash
# ==============================================================================
# firewall.sh — UFW firewall management: start, stop, flush, status, defaults
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# Ref        : my firewall my way

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
Usage: $PROGNAME [OPTIONS] COMMAND

Manages UFW firewall rules.

Commands:
  --start     Enable the firewall
  --stop      Disable the firewall
  --flush     Reset (flush) all firewall rules
  --status    Show verbose firewall status
  --default   Apply the default opinionated ruleset and reload
  --log       Follow kernel UFW log entries via dmesg

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message

Example:
  $PROGNAME --status
  $PROGNAME --default
  $PROGNAME --flush
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
            --)           shift; break ;;
            -*)           break ;;  # pass remaining flags to main for command handling
            *)            break ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# Firewall functions
# ------------------------------------------------------------------------------
flushIptables() {
    _run ufw reset
    warn "firewall rule(s) are flushed"
}

apply_default_rules() {
    _run ufw enable
    # Deny in and out both (Allow-only policy)
    _run ufw default deny outgoing
    _run ufw default deny incoming

    # Mind the gap (SSH — DO NOT CHANGE)
    # ssh -T git@github.com
    _run ufw deny in 22/tcp
    _run ufw allow out 22/tcp

    # Allow only...

    # Webserver
    _run ufw allow in 80/tcp
    _run ufw allow out 80/tcp
    _run ufw allow in 443/tcp
    _run ufw allow out 443/tcp
    _run ufw allow out to any port 53

    # Email stuff
    _run ufw allow in smtp
    _run ufw reject out smtp

    # Speedtest.net
    _run ufw allow out to any port 5060
    _run ufw allow out to any port 8080
    _run ufw allow out to any port 554
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    parse_args "$@"
    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    # Re-parse remaining positional/command arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose) shift ;;  # already handled
            --start)
                shift
                section "Starting Firewall"
                _run ufw enable
                ok "Firewall started."
                ;;
            --stop)
                shift
                section "Stopping Firewall"
                _run ufw disable
                ok "Firewall stopped."
                ;;
            --flush)
                shift
                section "Flushing Firewall Rules"
                flushIptables
                ok "Firewall rules flushed."
                ;;
            --status)
                shift
                section "Firewall Status"
                _run ufw status verbose
                ;;
            --default)
                shift
                section "Applying Default Firewall Rules"
                apply_default_rules
                _run ufw reload
                ok "Default firewall rules applied and reloaded."
                ;;
            --log)
                shift
                section "UFW Kernel Log"
                _run dmesg -w | grep '\[UFW'
                ;;
            *)
                fatal "Unknown command: '$1'. Use -h for help."
                ;;
        esac
    done
}

main "$@"
