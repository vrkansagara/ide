#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi
# System specific stuff
${SUDO} apt-get install --reinstall ca-certificates

echo "Application related stuff..."
${SUDO} apt-get install -y git meld vim-gtk ack silversearcher-ag build-essential cmake vim-nox python3-dev markdown
${SUDO} apt-get install -y libxml2-utils #xmllint

${SUDO} apt-get install -y zsh guake ufw geany

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Installing network realated stuf "
# Use `nmtui=wireless command line`
${SUDO} apt-get install -y iputils-ping net-tools lsof nmap whois network-manager

echo "System related stuff "
${SUDO} apt-get install -y elinks htop ctags vim curl lsb-release

read -r -p "Do you want to install XFCE desktop ? [Y/n] " input
case $input in
    [yY][eE][sS]|[yY])
		echo "Install desktop manager"
		${SUDO} apt-get install -y xfce4 xfce4-goodies
 ;;
    [nN][oO]|[nN])
 echo "Skipping...XFCE"
       ;;
    *)
 echo "Invalid input..."
 exit 1
 ;;
esac

${SUDO} apt-get install -y nginx nginx-full php
${SUDO} apt-get autoremove

echo "Install composer2 globaly"

echo "[DONE] My required linux binary installation id done."

exit 0
