# Ref:- https://javapipe.com/blog/iptables-ddos-protection/
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X
sudo iptables -t raw -F
sudo iptables -t raw -X

### DDOS Protection
echo "Block Invalid Packets"
sudo iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP

echo "Block New Packets That Are Not SYN"
sudo iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

echo "Block Uncommon MSS Values"
sudo iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP

echo "Block Packets With Bogus TCP Flags"
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP

echo "Block Packets From Private Subnets (Spoofing)"
# sudo iptables -t mangle -A PREROUTING -s 224.0.0.0/3 -j DROP
# sudo iptables -t mangle -A PREROUTING -s 169.254.0.0/16 -j DROP
# sudo iptables -t mangle -A PREROUTING -s 172.16.0.0/12 -j DROP
# sudo iptables -t mangle -A PREROUTING -s 192.0.2.0/24 -j DROP
# sudo iptables -t mangle -A PREROUTING -s 192.168.0.0/16 -j DROP
# sudo iptables -t mangle -A PREROUTING -s 10.0.0.0/8 -j DROP
# sudo iptables -t mangle -A PREROUTING -s 0.0.0.0/8 -j DROP
# sudo iptables -t mangle -A PREROUTING -s 240.0.0.0/5 -j DROP
# sudo iptables -t mangle -A PREROUTING -s 127.0.0.0/8 ! -i lo -j DROP

echo "This drops all ICMP packets. ICMP is only used to ping a host to find out if it’s still alive"
sudo iptables -t mangle -A PREROUTING -p icmp -j DROP
sudo iptables -A INPUT -p tcp -m connlimit --connlimit-above 80 -j REJECT --reject-with tcp-reset
sudo iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT
sudo iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP
sudo iptables -t mangle -A PREROUTING -f -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
sudo iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP
sudo iptables -t raw -A PREROUTING -p tcp -m tcp --syn -j CT --notrack
sudo iptables -A INPUT -p tcp -m tcp -m conntrack --ctstate INVALID,UNTRACKED -j SYNPROXY --sack-perm --timestamp --wscale 7 --mss 1460
sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP


### SSH brute-force protection ###
sudo iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set
sudo iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP

### Protection against port scanning ###
sudo iptables -N port-scanning
sudo iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
sudo iptables -A port-scanning -j DROP

echo "[filter] table list"
sudo iptables --table filter --list
echo "[nat] table list"
sudo iptables --table nat --list
echo "[mangle] table list"
sudo iptables --table mangle --list
echo "[raw] table list"
sudo iptables --table raw --list
echo "[security] table list"
sudo iptables --table security --list
