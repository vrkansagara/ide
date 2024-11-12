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
#  Note		  :- Controll nodejs process using cputool
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt-get install --yes --no-install-recommends cputool cpulimit

PROCESS_NAME="firefox"

while true; do
	clear

	TARGETS_PROCESS_PIDS=$(/bin/ps -fu $USER | grep -i "${PROCESS_NAME}" | grep -v "grep" | awk '{print $2}')

	for pid in $TARGETS_PROCESS_PIDS; do
		echo "${PROCESS_NAME} PID is [$pid] "
		# /usr/bin/cputool -c 5 -p $pid &
		# ${SUDO} kill -9 $pid
	done

	sleep 5

done
