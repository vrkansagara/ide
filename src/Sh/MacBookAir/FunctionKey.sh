#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo
echo "Current function mode setting is set as = "
${SUDO} cat /sys/module/hid_apple/parameters/fnmode

${SUDO} bash -c "echo 2 > /sys/module/hid_apple/parameters/fnmode"

# echo options hid_apple fnmode=2 | ${SUDO} tee -a /etc/modprobe.d/hid_apple.conf
# ${SUDO} update-initramfs -u -k all
# ${SUDO} reboot # optional

echo "Enabling tap to click for the MacBokAir track pad."
${SUDO} mkdir -p /etc/X11/xorg.conf.d
echo 'Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
        Option "Tapping" "on"
EndSection' | ${SUDO} tee /etc/X11/xorg.conf.d/40-libinput.conf  >/dev/null
# systemctl restart lightdm

gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'


echo "[DONE] MacBokAir Specific setting updated"
exit 0
