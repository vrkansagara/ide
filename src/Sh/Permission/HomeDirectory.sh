#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo " "
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Linux home directory permission, Linux way !
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

echo "SSH must be with golden permission of SSH way"
${SUDO} chmod a+trwx /tmp
${SUDO} chmod 0700 $HOME/.ssh
${SUDO} chmod 0600 $HOME/.ssh/id_*
${SUDO} chmod 0600 $HOME/.ssh/id_rsa_vrkansagara
${SUDO} chmod 0700 $HOME/.ssh/*.pub

echo "User [ $USER ] is the only one who owning the [ $HOME ] directory"
${SUDO} chown $USER:$USER -Rf $HOME

echo "Current user [ $USER ] has all the rights to change [ $HOME ] directory and it's file(s)."
${SUDO} chmod 0755 -Rf $HOME

echo "[DONE] Linux home directory permission applied."

exit 0
