#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

echo -n " "
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Install screen short tool.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# shutter project has issue with selection of window so lets move to xorg first
if [ -f "/etc/gdm3/custom.conf" ]; then
	# Change WaylandEnable=false to this file /etc/gdm3/custom.conf
	if [[ 'wayland' == $XDG_SESSION_TYPE ]]; then
		echo $XDG_SESSION_TYPE
		${SUDO} sed -i 's/#WaylandEnable=false/WaylandEnable=false/g' /etc/gdm3/custom.conf
	fi
fi

${SUDO} apt-get purge shutter
${SUDO} add-apt-repository ppa:shutter/ppa
${SUDO} apt-get update #for Linux Mint only, this is done automatically on Ubuntu
${SUDO} apt-get install shutter libappindicator-dev gir1.2-appindicator3-0.1
${SUDO} cpan -i Gtk2::AppIndicator
