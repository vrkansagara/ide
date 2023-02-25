#!/usr/bin/env bash
set -ev # This setting is telling the script to exit on a command error.
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
#  Note		  :- deb [arch=amd64] https://swupdate.openvpn.net/community/openvpn3/repos jammy main
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

echo 'Current architecture is :- ' $(dpkg --print-architecture)
DISTRO=$(lsb_release -cs)

${SUDO} apt-get install \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg \
	lsb-release
	${SUDO} curl -fsSL https://swupdate.openvpn.net/repos/openvpn-repo-pkg-key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/openvpn-repo-pkg-keyring.gpg
  ${SUDO} curl -fsSL https://swupdate.openvpn.net/community/openvpn3/repos/openvpn3-$DISTRO.list >/etc/apt/sources.list.d/openvpn3.list
  #	deb [arch=amd64] https://swupdate.openvpn.net/community/openvpn3/repos jammy main
	${SUDO} apt update
	sleep(3)
	${SUDO} apt install openvpn3