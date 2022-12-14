#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# Change system dns to public dns

#echo "nameserver 1.1.1.1" | ${SUDO} tee /etc/resolv.conf
#echo "nameserver 8.8.8.8" | ${SUDO} tee -a /etc/resolv.conf
#echo "nameserver 8.8.4.4" | ${SUDO} tee -a /etc/resolv.conf

cd /tmp
mkdir /tmp/applications
cd /tmp/applications
wget https://www.torproject.org/dist/torbrowser/10.5a15/tor-browser-linux64-10.5a15_en-US.tar.xz
wget https://www.torproject.org/dist/torbrowser/10.5a15/tor-browser-linux64-10.5a15_en-US.tar.xz.asc

