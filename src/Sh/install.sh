#!/usr/bin/env bash

# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" \]; then
	SUDO=sudo
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- This is the system setup script.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# System specific stuff
${SUDO} apt-get install --reinstall ca-certificates

echo "Application related stuff..."
${SUDO} apt-get install -y git meld vim-gtk ack silversearcher-ag build-essential cmake vim-nox python3-dev markdown
${SUDO} apt-get install -y git curl meld ack silversearcher-ag build-essential cmake make gcc libncurses5-dev libncursesw5-dev python3-dev markdown clipit fontconfig
${SUDO} apt-get install -y libxml2-utils #xmllint

${SUDO} apt-get install -y zsh guake ufw geany httrack keepassxc


if [ ! -d "$HOME/.oh-my-zsh" ]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "Installing network realated stuf "
# Use `nmtui=wireless command line`
${SUDO} apt-get install -y iputils-ping net-tools lsof nmap whois
network-manager wicd wicd-wicd-cli wicd-gtk wicd-curses

echo "System related stuff "
${SUDO} apt-get install -y elinks htop exuberant-ctags curl lsb-release remmina

read -r -p "Do you want to install XFCE desktop ? [Y/n] " input
case $input in
    [yY][eE][sS]|[yY])
		echo "Install desktop manager"
		${SUDO} apt-get install -y xfce4 xfce4-goodies
		${SUDO} apt-get install --reinstall thunar-volman gvfs-backends go-mtpfs mtp
 ;;
    [nN][oO]|[nN])
 echo "Skipping...XFCE"
       ;;
    *)
 echo "Invalid input..."
 exit 1
 ;;
esac

# cd /tmp
# wget https://golang.org/dl/go1.16.3.linux-amd64.tar.gz 
# ${SUDO} rm -rf /usr/local/go
# ${SUDO} tar -C /usr/local -xzf go1.16.3.linux-amd64.tar.gz

${SUDO} apt-get install -y nginx nginx-full php
${SUDO} apt-get autoremove

echo "[DONE] My required linux binary installation id done."

exit 1
