#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

echo " "
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# echo "Print current system theme ( Default :- Ambiance )"
# gsettings get org.gnome.desktop.interface gtk-theme

${SUDO} localedef -f UTF-8 -i en_US en_US.UTF-8

h=$(date +"%H")
if [ $h -gt 6 -a $h -le 12 ]; then
	echo good morning
	~/.vim/bin/brightness.sh set 900
	# brightness.sh set 30000
	# gsettings set org.gnome.desktop.interface gtk-theme 'Ambiance'
elif [ $h -gt 12 -a $h -le 16 ]; then
	echo good afternoon
	~/.vim/bin/brightness.sh set 700
	# gsettings set org.gnome.desktop.interface gtk-theme 'Ambiance'
elif [ $h -gt 16 -a $h -le 20 ]; then
	echo good evening
	~/.vim/bin/brightness.sh set 500
	# gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
else
	echo good night
	~/.vim/bin/brightness.sh set 300
	# gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
fi

if [ -d "/sys/module/hid_apple" ]; then
	echo "Current function mode setting is set as = "
	${SUDO} cat /sys/module/hid_apple/parameters/fnmode
	${SUDO} bash -c "echo 2 > /sys/module/hid_apple/parameters/fnmode"
#  echo options hid_apple fnmode=2 | ${SUDO} tee -a /etc/modprobe.d/hid_apple.conf
fi
# ${SUDO} update-initramfs -u -k all
# ${SUDO} reboot # optional

if [ ! -d "/etc/X11/xorg.conf.d" ]; then
	echo "Enabling tap to click for the MacBokAir track pad."
	${SUDO} mkdir -p /etc/X11/xorg.conf.d
else
	# sudo apt install libinput-tools
	echo 'Section "InputClass"
  Identifier "libinput touchpad catchall"
  MatchIsTouchpad "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
  Option "Tapping" "on"
  Option "NaturalScrolling" "true"
  EndSection' | ${SUDO} tee /etc/X11/xorg.conf.d/40-libinput.conf >/dev/null
	# ${SUDO} systemctl restart lightdm
fi

# helpful into kernel development
${SUDO} sh -c "echo 7 4 1 7 > /proc/sys/kernel/printk"

echo "MacBokAir Specific setting updated ... [DONE]"

exit 0
