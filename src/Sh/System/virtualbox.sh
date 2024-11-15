#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
	shift
fi

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- VirtualBox installation script.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
cd /tmp
wget https://download.virtualbox.org/virtualbox/6.1.30/virtualbox-6.1_6.1.30-148432~Debian~bullseye_amd64.deb

${SUDO} dpkg -i virtualbox-6.1_6.1.30-148432~Debian~bullseye_amd64.deb
${SUDO} apt-get update

exit 0
