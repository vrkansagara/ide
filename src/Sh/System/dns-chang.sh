#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

export CURRENT_DATE="$(date "+%Y%m%d%H%M%S")"

if [ "$(whoami)" != "root" ]; then
  SUDO=sudo
fi

if [ -n "$(uname -a | grep -i Ubuntu)" ]; then
  if [ "$(lsb_release -sc)" == 'jammy' ]; then
    ${SUDO} nmcli networking off
    ${SUDO} nmcli networking on
  fi
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :- Change dns for latency improvement
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo "$0 execution ... [STARTED - ${CURRENT_DATE}]"

${SUDO} apt install dos2unix

if [ -f "/etc/resolv.conf" ]; then
  # Lets backup the resolver
  ${SUDO} cp /etc/resolv.conf /etc/resolv-${CURRENT_DATE}.conf

  # Change system dns to public dns
  echo "# cloudflare.com (https://1.1.1.1/help)" | ${SUDO} tee /etc/resolv.conf >/dev/null
  echo "nameserver 1.1.1.1" | ${SUDO} tee -a /etc/resolv.conf >/dev/null
  echo "nameserver 1.0.0.1" | ${SUDO} tee -a /etc/resolv.conf >/dev/null
  echo "nameserver 2606:4700:4700::1111" | ${SUDO} tee -a /etc/resolv.conf >/dev/null
  echo "nameserver 2606:4700:4700::1001" | ${SUDO} tee -a /etc/resolv.conf >/dev/null

  echo "# Google DNS" | ${SUDO} tee -a /etc/resolv.conf >/dev/null
  echo "nameserver 8.8.8.8" | ${SUDO} tee -a /etc/resolv.conf >/dev/null
  echo "nameserver 8.8.4.4" | ${SUDO} tee -a /etc/resolv.conf >/dev/null
  echo "nameserver 2001:4860:4860::8888" | ${SUDO} tee -a /etc/resolv.conf >/dev/null
  echo "nameserver 2001:4860:4860::8844" | ${SUDO} tee -a /etc/resolv.conf >/dev/null

  # change file attributes on a Linux file system
  #  ${SUDO} chattr +i /etc/resolv.conf >/dev/null
  # Use the realpath for the resolver and modified the attributes to avoid symbolic link issue.
  ${SUDO} dos2unix "$(realpath /etc/resolv.conf)"
  ${SUDO} chattr -f +i "$(realpath /etc/resolv.conf)" >/dev/null

  # Check weather the dns query is failling to resolve
  # ${SUDO} tcpdump -ni any port 53 | tee -a /tmp/dns_problem.log
  # tail -f /tmp/dns_problem.log
fi

cat /etc/resolv.conf

function flush_dns_for_hosts() {
  declare -a DOMAINS=("google.com" "vrkansagara.in" "example.com")
  ## now loop through the above array
  for DOMAIN in "${DOMAINS[@]}"; do
    echo "Running for the domain $DOMAIN"
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

echo "$0 execution ... [DONE - ${CURRENT_DATE}]"

exit 0
