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

echo "$USER is the only one is owning the $HOME/.ssh directory"

${SUDO} chown $USER:$USER -Rf $HOME/.ssh

echo "Generating sample SSH key"
ssh-keygen -t ed25519 -C "hello@vrkansagara.in"
ssh-keygen -t rsa -b 4096 -C "hello-world@vrkansagara.in"

echo "SSH must be with golden permission of SSH way"
${SUDO} chmod 0700 $HOME/.ssh
${SUDO} chmod 0600 $HOME/.ssh/id_rsa*
${SUDO} chmod 0700 $HOME/.ssh/*.pub


echo "[DONE] Linux $HOME/.ssh directory permission applied."
exit 0
