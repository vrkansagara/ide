#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
	shift
fi

if [ "$(uname -s)" == 'Darwin' ]; then
    exit 0;
fi

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

echo -e "Script [$0] started in [$SCRIPTDIR]"

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Ubuntu no password for the current user
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} touch /etc/sudoers.d/90-cloud-init-users

# User rules for ubuntu (only tee - replace file)
echo "$USER ALL=(ALL) NOPASSWD:ALL" | ${SUDO} tee /etc/sudoers.d/90-cloud-init-users

echo "User [$USER] does not require to enter password."

exit 0
