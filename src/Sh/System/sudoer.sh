#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

echo ""
export
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
SCRIPT=$(readlink -f "")
SCRIPTDIR=$(dirname "$SCRIPT")

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

echo -e "Script [$0] started in [$SCRIPTDIR] at  $CURRENT_DATE"

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Ubuntu no password for the current user
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} touch /etc/sudoers.d/90-cloud-init-users

# User rules for ubuntu (only tee - replace file)
echo "$USER ALL=(ALL) NOPASSWD:ALL" | ${SUDO} tee /etc/sudoers.d/90-cloud-init-users

echo "User [$USER] does not require to enter password."

exit 0
