#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt-get install --no-install-recommends build-essential fakeroot devscripts linux-image-$(uname -r)

# echo "deb-src http://archive.ubuntu.com/ubuntu $(lsb_release -cs) main" | ${SUDO} tee -a /etc/apt/sources.list
# echo "deb-src http://archive.ubuntu.com/ubuntu $(lsb_release -cs)-updates main" | ${SUDO} tee -a /etc/apt/sources.list
