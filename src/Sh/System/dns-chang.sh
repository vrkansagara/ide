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

# Change system dns to public dns
echo "nameserver 1.1.1.1" | ${SUDO} tee /etc/resolv.conf > /dev/null
echo "nameserver 8.8.8.8" | ${SUDO} tee -a /etc/resolv.conf > /dev/null
echo "nameserver 8.8.4.4" | ${SUDO} tee -a /etc/resolv.conf > /dev/null

${SUDO} chattr +i /etc/resolv.conf > /dev/null
