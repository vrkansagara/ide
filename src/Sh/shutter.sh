#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Install screen short tool.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} add-apt-repository ppa:shutter/ppa
${SUDO} apt-get update #for Linux Mint only, this is done automatically on Ubuntu
${SUDO} apt-get install shutter libgoo-canvas-perl libgtk2-appindicator-perl libappindicator-dev
${SUDO} cpan -i Gtk2::AppIndicator
