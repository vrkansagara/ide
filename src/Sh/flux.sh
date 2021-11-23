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
#  Note		  :- Brightness dim after sunset and sunrise
#  Github	  :- https://github.com/xflux-gui/fluxgui
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


${SUDO} add-apt-repository ppa:nathan-renniewaldock/flux
${SUDO} apt-get update
${SUDO} apt-get install -y fluxgui

