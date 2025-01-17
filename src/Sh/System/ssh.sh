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
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt-get install --no-install-recommends keychain

echo "$USER is the only one is owning the $HOME/.ssh directory"

echo 'Host *
AddKeysToAgent yes
IdentityFile ~/.ssh/id_rsa
IdentityFile ~/.ssh/id_rsa_vrkansagara
' | ${SUDO} tee -a ~/.ssh/config >/dev/null

#${SUDO} chown $USER:$USER -Rf $HOME/.ssh

echo "Generating sample SSH key"
cd $HOME/.ssh

# ssh-keygen -t ed25519 -C "hello@vrkansagara.in"
# ssh-keygen -t rsa -b 4096 -C "hello-world@vrkansagara.in"
# ssh-keygen -t rsa -b 4096 -C "ubuntu@raspberrypi"

echo "SSH must be with golden permission of SSH way"
${SUDO} chmod 0700 $HOME/.ssh
${SUDO} chmod 0600 $HOME/.ssh/id_rsa*
${SUDO} chmod 0600 $HOME/.ssh/id_ed*
${SUDO} chmod 0700 $HOME/.ssh/*.pub

eval "$(ssh-agent -s)"

if [ -f "$HOME/.ssh/id_rsa" ]; then
  ssh-add $HOME/.ssh/id_rsa
fi

if [ -f "$HOME/.ssh/id_rsa_vrkansagara" ]; then
  ssh-add $HOME/.ssh/id_rsa_vrkansagara
fi

if [ -f "~/.ssh/gnupg/vrkansagara-sec.key" ]; then
  gpg --import ~/.ssh/gnupg/vrkansagara-sec.key
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
