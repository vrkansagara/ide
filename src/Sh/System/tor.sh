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


cd /tmp
mkdir /tmp/applications
cd /tmp/applications
wget https://www.torproject.org/dist/torbrowser/10.5a15/tor-browser-linux64-10.5a15_en-US.tar.xz
wget https://www.torproject.org/dist/torbrowser/10.5a15/tor-browser-linux64-10.5a15_en-US.tar.xz.asc

