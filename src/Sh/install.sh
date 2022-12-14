#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- This is the system setup script.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# https://unix.stackexchange.com/questions/175810/how-to-install-broadcom-bcm4360-on-debian-on-macbook-pro
${SUDO} apt-get install --no-install-recommends linux-image-$(uname -r|sed 's,[^-]*-[^-]*-,,') linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') broadcom-sta-dkms
${SUDO} modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
${SUDO} modprobe wl

# ${SUDO} sudo apt install --no-install-recommends --no-install-suggests \
# vim geany git build-essential htop sudo xorg xserver-xorg xinit \
# libxft-dev libxinerama-dev xbacklight wget curl zsh \
# software-properties-common

# echo 10 | sudo tee /sys/class/backlight/acpi_video0/brightness
# echo 300 > /sys/class/backlight/intel_backlight/brightness

## Ubuntu specific
# Do not upgrade to latest release
${SUDO} sed -i 's/Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades

# System specific stuff
${SUDO} apt-get install --reinstall ca-certificates

echo "Application related stuff..."
${SUDO} apt-get install -y git meld vim-gtk ack silversearcher-ag build-essential cmake vim-nox python3-dev markdown
${SUDO} apt-get install -y git curl meld ack silversearcher-ag build-essential cmake make gcc libncurses5-dev libncursesw5-dev python3-dev markdown diodon fontconfig
${SUDO} apt-get install -y libxml2-utils #xmllint

${SUDO} apt-get install -y zsh guake ufw geany httrack keepassxc cpulimit jq

echo "Guake specific issue fixing."
${SUDO} apt-get install libutempter0

echo "Installing nodejs "
curl -fsSL https://deb.nodesource.com/setup_14.x | ${SUDO} -E bash -
${SUDO} apt-get install -y nodejs

if [ ! -d "$HOME/.oh-my-zsh" ]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "Installing network realated stuf "
# Use `nmtui=wireless command line`
${SUDO} apt-get install -y iputils-ping net-tools lsof nmap whois network-manager wicd wicd-wicd-cli wicd-gtk wicd-curses

echo "System related stuff "
${SUDO} apt-get install -y elinks htop exuberant-ctags curl lsb-release remmina

read -r -p "Do you want to install XFCE desktop ? [Y/n] " input
case $input in
	[yY][eE][sS]|[yY])
		echo "Install desktop manager"
		${SUDO} apt-get install -y xfce4 xfce4-goodies
		${SUDO} apt-get install --reinstall thunar-volman gvfs-backends go-mtpfs mtp gmtp
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

${SUDO} apt-get install -y nginx nginx-full php composer
${SUDO} useradd $USER -g www-data
${SUDO} chown -R $USER:www-data $HOME/htdocs $HOME/www

${SUDO} apt-get autoremove

# Adding current use to virtual box
${SUDO} adduser $USER vboxsf

echo "AllowRoot=root" | ${SUDO}  tee -a /etc/gdm3/custom.conf
echo "AutomaticLogin=$(whoami)" | ${SUDO}  tee -a /etc/gdm3/custom.conf
echo "greeter-show-manual-login=true" | ${SUDO} /etc/lightdm/lightdm.conf

# reset htop configuration
${SUDO} rm -rf $HOME/.config/htop/htoprc

echo "[DONE] My required Linux binary installation id done."

exit 0
