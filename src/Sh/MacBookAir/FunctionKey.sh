#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo " "
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# echo "Print current system theme ( Default :- Ambiance )"
# gsettings get org.gnome.desktop.interface gtk-theme

${SUDO} localedef -f UTF-8 -i en_US en_US.UTF-8

h=$(date +"%H")
if [ $h -gt 6 -a $h -le 12 ]
then
	echo good morning
	# gsettings set org.gnome.desktop.interface gtk-theme 'Ambiance'
elif [ $h -gt 12 -a $h -le 16 ]
then
	echo good afternoon
	# gsettings set org.gnome.desktop.interface gtk-theme 'Ambiance'
elif [ $h -gt 16 -a $h -le 20 ]
then
	echo good evening
	# gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
else
	echo good night
	# gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
fi

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

# helpful into kernel developmen
${SUDO} sh -c "echo 7 4 1 7 > /proc/sys/kernel/printk"

echo "[DONE] MacBokAir Specific setting updated"

exit 0
