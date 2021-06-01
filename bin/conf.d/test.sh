#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Test shell script for the endless
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

while [ 1 ]; do
	CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
	echo "hello world.....I am going to sleep for 60 secounds from $CURRENT_DATE"
	sleep 10
done

