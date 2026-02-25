#!/usr/bin/env bash
# ==============================================================================
# dns-chang.sh — Change system DNS to Cloudflare and Google public DNS servers
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

  Change system DNS to Cloudflare (1.1.1.1) and Google (8.8.8.8) public DNS
  servers for latency improvement. Backs up the existing resolv.conf first.

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message
EOF
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

flush_dns_for_hosts() {
    declare -a DOMAINS=("google.com" "vrkansagara.in" "example.com")
    ## now loop through the above array
    for DOMAIN in "${DOMAINS[@]}"; do
        info "Running for the domain $DOMAIN"
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=A" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=AAAA" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=CAA" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=CNAME" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=DNSKEY" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=DS" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=HTTPS" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=LOC" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=MX" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=NAPTR" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=NS" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=PTR" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=SPF" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=SRV" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=SVCB" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=SSHFP" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=TLSA" &
        curl -X POST "https://1.1.1.1/api/v1/purge?domain=$DOMAIN&type=TXT" &
    done
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
    export CURRENT_DATE
    CURRENT_DATE="$(date "+%Y%m%d%H%M%S")"

    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    if [ -n "$(uname -a | grep -i Ubuntu)" ]; then
        if [ "$(lsb_release -sc)" == 'jammy' ]; then
            _run nmcli networking off
            _run nmcli networking on
        fi
    fi

    info "$0 execution ... [STARTED - ${CURRENT_DATE}]"

    _run apt install dos2unix

    if [ -f "/etc/resolv.conf" ]; then
        # Lets backup the resolver
        _run cp /etc/resolv.conf "/etc/resolv-${CURRENT_DATE}.conf"

        # Change system dns to public dns
        printf '# cloudflare.com (https://1.1.1.1/help)\n' | _run tee /etc/resolv.conf >/dev/null
        printf 'nameserver 1.1.1.1\n' | _run tee -a /etc/resolv.conf >/dev/null
        printf 'nameserver 1.0.0.1\n' | _run tee -a /etc/resolv.conf >/dev/null
        printf 'nameserver 2606:4700:4700::1111\n' | _run tee -a /etc/resolv.conf >/dev/null
        printf 'nameserver 2606:4700:4700::1001\n' | _run tee -a /etc/resolv.conf >/dev/null

        printf '# Google DNS\n' | _run tee -a /etc/resolv.conf >/dev/null
        printf 'nameserver 8.8.8.8\n' | _run tee -a /etc/resolv.conf >/dev/null
        printf 'nameserver 8.8.4.4\n' | _run tee -a /etc/resolv.conf >/dev/null
        printf 'nameserver 2001:4860:4860::8888\n' | _run tee -a /etc/resolv.conf >/dev/null
        printf 'nameserver 2001:4860:4860::8844\n' | _run tee -a /etc/resolv.conf >/dev/null

        # change file attributes on a Linux file system
        #  _run chattr +i /etc/resolv.conf >/dev/null
        # Use the realpath for the resolver and modified the attributes to avoid symbolic link issue.
        _run dos2unix "$(realpath /etc/resolv.conf)"
        _run chattr -f +i "$(realpath /etc/resolv.conf)" >/dev/null || true

        # Check weather the dns query is failling to resolve
        # _run tcpdump -ni any port 53 | tee -a /tmp/dns_problem.log
        # tail -f /tmp/dns_problem.log
    fi

    cat /etc/resolv.conf

    ok "$0 execution ... [DONE - ${CURRENT_DATE}]"
}

main "$@"
