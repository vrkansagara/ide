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
#  Note		  :- x automatin of keyboard and mouse
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if ! command -v xte &>/dev/null; then
	${SUDO} apt-get install -y xautomation
fi

while true; do
	sleep 30
	xte "keydown Super_L" "key Tab" "key Tab" "keyup Super_L"
	sleep 30
	xte "keydown Super_L" "key Tab" "keyup Super_L"
done
