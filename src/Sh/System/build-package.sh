#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo ""
export DEBIAN_FRONTEND=noninteractive
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
SCRIPT=$(readlink -f "")
SCRIPTDIR=$(dirname "$SCRIPT")

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- 
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt-get install build-essential fakeroot devscripts linux linux-image-$(uname -r)

echo "deb-src http://archive.ubuntu.com/ubuntu $(lsb_release -cs) main" | ${SUDO} tee -a /etc/apt/sources.list
echo "deb-src http://archive.ubuntu.com/ubuntu $(lsb_release -cs)-updates main" | ${SUDO} tee -a /etc/apt/sources.list
