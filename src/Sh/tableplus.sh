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
#  Note		  :- 
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# Ref:-https://tableplus.com/blog/2019/10/tableplus-linux-installation.html

# Add TablePlus gpg key
wget -qO - http://deb.tableplus.com/apt.tableplus.com.gpg.key | ${SUDO} apt-key add -

# Add TablePlus repo
${SUDO} add-apt-repository "deb [arch=amd64] https://deb.tableplus.com/debian tableplus main"

# Install
${SUDO} apt update
${SUDO} apt install tableplus
