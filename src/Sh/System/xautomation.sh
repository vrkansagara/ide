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

if ! command -v xte &> /dev/null
then
	${SUDO} apt-get install -y xautomation
fi

while true; do
	xte "mousermove 0 0" "keydown Alt_L" "key Tab" "keyup Alt_L" "mousermove 50 50"
	sleep 30
	xte "mousermove 0 0" "keydown Alt_L" "key Tab" "keyup Alt_L" "mousermove 50 50"
done
