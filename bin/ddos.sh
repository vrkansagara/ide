#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

if [ "$(whoami)" != "root" ]; then
  SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Ref        :- https://javapipe.com/blog/iptables-ddos-protection/
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} iptables -P FORWARD ACCEPT
${SUDO} iptables -P OUTPUT ACCEPT
${SUDO} iptables -F
${SUDO} iptables -X
${SUDO} iptables -t nat -F
${SUDO} iptables -t nat -X
${SUDO} iptables -t mangle -F
${SUDO} iptables -t mangle -X
${SUDO} iptables -t raw -F
${SUDO} iptables -t raw -X

### DDOS Protection
echo "Block Invalid Packets"
${SUDO} iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP

echo "Block New Packets That Are Not SYN"
${SUDO} iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

echo "Block Uncommon MSS Values"
${SUDO} iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP

echo "Block Packets With Bogus TCP Flags"
${SUDO} iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
${SUDO} iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
${SUDO} iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
${SUDO} iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
${SUDO} iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
${SUDO} iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
${SUDO} iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP

echo "Block Packets From Private Subnets (Spoofing)"
# ${SUDOi ptables -t mangle -A PREROUTING -s 224.0.0.0/3 -j DROP
# ${SUDOi ptables -t mangle -A PREROUTING -s 169.254.0.0/16 -j DROP
# ${SUDOi ptables -t mangle -A PREROUTING -s 172.16.0.0/12 -j DROP
# ${SUDOi ptables -t mangle -A PREROUTING -s 192.0.2.0/24 -j DROP
# ${SUDOi ptables -t mangle -A PREROUTING -s 192.168.0.0/16 -j DROP
# ${SUDOi ptables -t mangle -A PREROUTING -s 10.0.0.0/8 -j DROP
# ${SUDOi ptables -t mangle -A PREROUTING -s 0.0.0.0/8 -j DROP
# ${SUDOi ptables -t mangle -A PREROUTING -s 240.0.0.0/5 -j DROP
# ${SUDOi ptables -t mangle -A PREROUTING -s 127.0.0.0/8 ! -i lo -j DROP

echo "This drops all ICMP packets. ICMP is only used to ping a host to find out if it’s still alive"
${SUDO} iptables -t mangle -A PREROUTING -p icmp -j DROP
${SUDO} iptables -A INPUT -p tcp -m connlimit --connlimit-above 80 -j REJECT --reject-with tcp-reset
${SUDO} iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT
${SUDO} iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP
${SUDO} iptables -t mangle -A PREROUTING -f -j DROP
${SUDO} iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
${SUDO} iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP
${SUDO} iptables -t raw -A PREROUTING -p tcp -m tcp --syn -j CT --notrack
${SUDO} iptables -A INPUT -p tcp -m tcp -m conntrack --ctstate INVALID,UNTRACKED -j SYNPROXY --sack-perm --timestamp --wscale 7 --mss 1460
${SUDO} iptables -A INPUT -m conntrack --ctstate INVALID -j DROP


### SSH brute-force protection ###
${SUDO} iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set
${SUDO} iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP

### Protection against port scanning ###
${SUDO} iptables -N port-scanning
${SUDO} iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
${SUDO} iptables -A port-scanning -j DROP

echo "[filter] table list"
${SUDO} iptables --table filter --list
echo "[nat] table list"
${SUDO} iptables --table nat --list
echo "[mangle] table list"
${SUDO} iptables --table mangle --list
echo "[raw] table list"
${SUDO} iptables --table raw --list
echo "[security] table list"
${SUDO} iptables --table security --list