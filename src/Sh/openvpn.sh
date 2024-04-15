#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

echo CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo 'Current architecture is :- ' $(dpkg --print-architecture)

${SUDO} apt-get install \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg \
	lsb-release

	${SUDO} wget https://swupdate.openvpn.net/repos/openvpn-repo-pkg-key.pub

	${SUDO} apt-key add openvpn-repo-pkg-key.pub

	${SUDO} wget -O /etc/apt/sources.list.d/openvpn3.list https://swupdate.openvpn.net/community/openvpn3/repos/openvpn3-$(lsb_release -cs).list
	# [arch=amd64]

${SUDO} apt update

sleep(3)

${SUDO} apt install openvpn3
