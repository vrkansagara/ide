#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
# The shopt is a shell builtin command to set and unset (remove) various Bash shell options.
shopt -s extglob
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :- Linux home directory permission, Linux way !
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

echo "User [ $USER ] is the only one who owning the [ $HOME ] directory"
${SUDO} chown $USER:$USER -Rf $HOME/!(www|git) $HOME/.gnupg

echo "Current user [ $USER ] has all the rights to change [ $HOME ] directory and it's file(s)."
${SUDO} chmod 0755 -Rf $HOME/!(www|git)

echo "SSH must be with golden permission of SSH way"
${SUDO} chmod a+trwx /tmp ${HOME}/tmp
${SUDO} chmod 0700 $HOME/.ssh
${SUDO} chmod 0600 $HOME/.ssh/id_rsa*
${SUDO} chmod 0700 $HOME/.ssh/*.pub

${SUDO} find ~/.gnupg -type f -exec chmod 600 {} \;
${SUDO} find ~/.gnupg -type d -exec chmod 700 {} \;
${SUDO} chmod -R u=rw,u+X,go= ~/.gnupg

# ssh-keygen -p -m PEM -f ~/.ssh/id_rsa
# ssh-keygen -t rsa -b 2048 -m PEM -f ~/.ssh/id_rsa

echo "[DONE] Linux home directory permission applied."

exit 0
