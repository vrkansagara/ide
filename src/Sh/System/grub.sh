#!/usr/bin/env bash
# ==============================================================================
# grub.sh — Configure GRUB for compatibility with older hardware
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

  Back up /etc/default/grub and update GRUB_CMDLINE_LINUX_DEFAULT with
  settings suitable for older hardware (nosplash, intel_idle, fsck, etc.).
  Also runs update-grub and update-initramfs.

  Note: This script does not support macOS.

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

    if [[ "$(uname -s)" == 'Darwin' ]]; then
        fatal "This script does not support macOS."
    fi

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    section "Backing up GRUB configuration"
    local backup_path
    backup_path="$HOME/.vim/data/backup/grub-$(date '+%Y%m%d%H%M%S')"
    _run cp /etc/default/grub "$backup_path"
    info "Backup created: ${backup_path}"

    section "Applying GRUB settings for older hardware"
    _run sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet nosplash debug i915.enable_dc=0 ahci.mobile_lpm_policy=1 intel_idle.max_cstate=1 fsck.mode=force fsck.repair=yes intel_iommu=igfx_off"/' /etc/default/grub

    section "Updating GRUB and initramfs"
    _run update-grub
    _run update-initramfs -u

    section "Analyzing boot sequence"
    systemd-analyze plot > "$HOME/boot.svg"
    info "Boot analysis written to: $HOME/boot.svg"

    # inxi -Fxxxrz | grep -i 'driver\|acpi'

    ok "GRUB configuration complete."
    exit 0
}

main "$@"
