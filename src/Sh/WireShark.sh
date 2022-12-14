#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

echo
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Installation script for the wireshark.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} add-apt-repository ppa:wireshark-dev/stable
${SUDO} apt-get update
${SUDO} apt-get install wireshark
${SUDO} dpkg-reconfigure wireshark-common
${SUDO} adduser $USER wireshark
${SUDO} usermod -a -G wireshark $USER

