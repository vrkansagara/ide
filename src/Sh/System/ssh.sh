#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)
echo " "
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi
echo ""
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt-get install --no-install-recommends keychain

echo "$USER is the only one is owning the $HOME/.ssh directory"

echo 'Host *
AddKeysToAgent yes
IdentityFile ~/.ssh/id_rsa
IdentityFile ~/.ssh/id_rsa_vrkansagara
' | ${SUDO} tee -a ~/.ssh/config > /dev/null

${SUDO} chown $USER:$USER -Rf $HOME/.ssh

echo "Generating sample SSH key"
cd $HOME/.ssh

# ssh-keygen -t ed25519 -C "hello@vrkansagara.in"
# ssh-keygen -t rsa -b 4096 -C "hello-world@vrkansagara.in"

echo "SSH must be with golden permission of SSH way"
${SUDO} chmod 0700 $HOME/.ssh
${SUDO} chmod 0600 $HOME/.ssh/id_rsa*
${SUDO} chmod 0600 $HOME/.ssh/id_ed*
${SUDO} chmod 0700 $HOME/.ssh/*.pub

eval "$(ssh-agent -s)"
ssh-add $HOME/.ssh/id_rsa
ssh-add $HOME/.ssh/id_rsa_vrkansagara

if [ -f "~/.ssh/gnupg/vrkansagara.pgp" ]; then
  gpg --import ~/.ssh/gnupg/vrkansagara.pgp
fi

echo "[DONE] Linux $HOME/.ssh directory permission applied."
exit 0
#
#" Host *
#" UseKeychain yes
#" AddKeysToAgent yes
#" IdentityFile ~/.ssh/id_rsa
## mysql could not connect the SSH tunnel -> access denied for 'none'
## ssh-keygen -p -m PEM -f
