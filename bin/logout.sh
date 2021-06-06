#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" == "root" ]; then
	echo "This script does not support root level execution."
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Logout of the current user(DONT USE FOR THE ROOT)
#				 kill -9 -1 kills all processes owned by the user executing it,
#				 except for the shell you executed it from, with exception to
#				 root users.

echo "Current use is going to logout $USER  "

kill -9 -1
