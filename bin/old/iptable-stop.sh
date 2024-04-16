#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

echo
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# ${SUDO} apt-get install --yes --no-install-recommends iptables nscd
# issue fix : Failed to flush caches: Unit dbus-org.freedesktop.resolve1.service not found.
# ${SUDO} ln -sf /lib/systemd/system/systemd-resolved.service /etc/systemd/system/dbus-org.freedesktop.resolve1.service

# My system IP/set ip address of server
SERVER_IP="192.168.1.7"

echo "Stopping IPv4 firewall and allowing everyone..."
ipt="/usr/sbin/iptables"

## Failsafe - die if /sbin/iptables not found
[ ! -x "$ipt" ] && {
	echo "$0: \"${ipt}\" command not found."
	exit 1
}
${SUDO} $ipt -t filter -F
${SUDO} $ipt -t filter -X
${SUDO} $ipt -t nat -F
${SUDO} $ipt -t nat -X
${SUDO} $ipt -t mangle -F
${SUDO} $ipt -t mangle -X
${SUDO} $ipt -t raw -F
${SUDO} $ipt -t raw -X
${SUDO} $ipt -t security -F
${SUDO} $ipt -t security -X
${SUDO} $ipt -F
${SUDO} $ipt -X
${SUDO} $ipt -P INPUT ACCEPT
${SUDO} $ipt -P FORWARD ACCEPT
${SUDO} $ipt -P OUTPUT ACCEPT
${SUDO} $ipt -L

# How do I clear the DNS cache?
${SUDO} systemd-resolve --flush-caches
${SUDO} systemctl enable systemd-resolved.service
${SUDO} /etc/init.d/networking restart
# Flush nscd dns cache:
${SUDO} /etc/init.d/nscd restart
${SUDO} systemd-resolve --statistics
# ${SUDO}  /etc/init.d/dns-clean start
sleep 5s # Waits 5 seconds.

# Setting default filter policy
# ${SUDO} $ipt -P INPUT DROP
# ${SUDO} $ipt -P OUTPUT DROP
# ${SUDO} $ipt -P FORWARD DROP
# Allow unlimited traffic on loopback
# ${SUDO} $ipt -A INPUT -i lo -j ACCEPT
# ${SUDO} $ipt -A OUTPUT -o lo -j ACCEPT
# Allow incoming ssh only
# ${SUDO} $ipt -A INPUT -p tcp -s 0/0 -d $SERVER_IP --sport 513:65535 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
# ${SUDO} $ipt -A OUTPUT -p tcp -s $SERVER_IP -d 0/0 --sport 22 --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT

# make sure nothing comes or goes out of this box
# ${SUDO} $ipt -A INPUT -j DROP
# ${SUDO} $ipt -A OUTPUT -j DROP
##################################################################

# ${SUDO} $ipt  -I INPUT -s 142.250.182.195 -j REJECT

# ${SUDO} $ipt -A INPUT -s 3.0.0.0/9 -j DROP
# ${SUDO} $ipt -A INPUT -s 3.6.0.0/15 -j DROP
# ${SUDO} $ipt -A OUTPUT -p 53 -d datashield.in -j DROP

# ${SUDO} $ipt -A INPUT -s fonts.gstatic.com -j DROP
# ${SUDO} $ipt -A OUTPUT -d fonts.gstatic.com -j DROP

${SUDO} $ipt -L -n -t nat -v
${SUDO} $ipt -L --line-numbers

echo "Iptables stop script done......"
exit 0

# Allow loopback
${SUDO} $ipt -I INPUT 1 -i lo -j ACCEPT

# Allow DNS
${SUDO} $ipt -A OUTPUT -p udp --dport 53 -j ACCEPT

# Now, allow connection to website serverfault.com on port 80
${SUDO} $ipt -A OUTPUT -p tcp -d gocomics.com --dport 443 -j ACCEPT
${SUDO} $ipt -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Drop everything
${SUDO} $ipt -P INPUT DROP
${SUDO} $ipt -P OUTPUT DROP
