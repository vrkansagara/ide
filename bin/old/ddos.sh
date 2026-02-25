#!/usr/bin/env bash
# ==============================================================================
# ddos.sh — apply iptables DDoS protection, SSH brute-force and port scan rules
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# Ref        : https://javapipe.com/blog/iptables-ddos-protection/

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
    printf 'Usage: %s [OPTIONS]\n\n' "$PROGNAME"
    printf 'Apply iptables DDoS protection, SSH brute-force and port scan mitigation rules.\n\n'
    printf 'Options:\n'
    printf '  -v, --verbose    Enable verbose/debug output\n'
    printf '      --version    Print version and exit\n'
    printf '  -h, --help       Show this help message\n'
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose)  VERBOSE=1 ;;
            --version)     printf '%s version %s\n' "$PROGNAME" "$VERSION"; exit 0 ;;
            -h|--help)     usage; exit 0 ;;
            *)             fatal "Unknown option: $1" ;;
        esac
        shift
    done
}

main() {
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    section "Flushing existing iptables rules"
    _run iptables -P FORWARD ACCEPT
    _run iptables -P OUTPUT ACCEPT
    _run iptables -F
    _run iptables -X
    _run iptables -t nat -F
    _run iptables -t nat -X
    _run iptables -t mangle -F
    _run iptables -t mangle -X
    _run iptables -t raw -F
    _run iptables -t raw -X

    ### DDOS Protection
    section "Applying DDoS protection rules"
    info "Block Invalid Packets"
    _run iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP

    info "Block New Packets That Are Not SYN"
    _run iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

    info "Block Uncommon MSS Values"
    _run iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP

    info "Block Packets With Bogus TCP Flags"
    _run iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
    _run iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
    _run iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
    _run iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
    _run iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
    _run iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
    _run iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP

    info "Block Packets From Private Subnets (Spoofing)"
    # _run iptables -t mangle -A PREROUTING -s 224.0.0.0/3 -j DROP
    # _run iptables -t mangle -A PREROUTING -s 169.254.0.0/16 -j DROP
    # _run iptables -t mangle -A PREROUTING -s 172.16.0.0/12 -j DROP
    # _run iptables -t mangle -A PREROUTING -s 192.0.2.0/24 -j DROP
    # _run iptables -t mangle -A PREROUTING -s 192.168.0.0/16 -j DROP
    # _run iptables -t mangle -A PREROUTING -s 10.0.0.0/8 -j DROP
    # _run iptables -t mangle -A PREROUTING -s 0.0.0.0/8 -j DROP
    # _run iptables -t mangle -A PREROUTING -s 240.0.0.0/5 -j DROP
    # _run iptables -t mangle -A PREROUTING -s 127.0.0.0/8 ! -i lo -j DROP

    info "This drops all ICMP packets. ICMP is only used to ping a host to find out if it's still alive"
    _run iptables -t mangle -A PREROUTING -p icmp -j DROP
    _run iptables -A INPUT -p tcp -m connlimit --connlimit-above 80 -j REJECT --reject-with tcp-reset
    _run iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT
    _run iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP
    _run iptables -t mangle -A PREROUTING -f -j DROP
    _run iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
    _run iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP
    _run iptables -t raw -A PREROUTING -p tcp -m tcp --syn -j CT --notrack
    _run iptables -A INPUT -p tcp -m tcp -m conntrack --ctstate INVALID,UNTRACKED -j SYNPROXY --sack-perm --timestamp --wscale 7 --mss 1460
    _run iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

    ### SSH brute-force protection ###
    section "Applying SSH brute-force protection"
    _run iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set
    _run iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP

    ### Protection against port scanning ###
    section "Applying port scan protection"
    _run iptables -N port-scanning
    _run iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
    _run iptables -A port-scanning -j DROP

    section "Listing iptables tables"
    info "[filter] table list"
    _run iptables --table filter --list
    info "[nat] table list"
    _run iptables --table nat --list
    info "[mangle] table list"
    _run iptables --table mangle --list
    info "[raw] table list"
    _run iptables --table raw --list
    info "[security] table list"
    _run iptables --table security --list

    ok "DDoS protection rules applied."
}
main "$@"
