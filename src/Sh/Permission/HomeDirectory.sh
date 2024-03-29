#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

echo " "
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Linux home directory permission, Linux way !
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

echo "User [ $USER ] is the only one who owning the [ $HOME ] directory"
if [ $(uname -s) == 'Darwin' ]; then
	# Resetting home directory permissions on macOS
	chflags -R nouchg ~
	diskutil resetUserPermissions / $(id -u)
	# ${SUDO} chown -R $USER:staff $HOME
	# ${SUDO} chmod -R 600 ~
	# ${SUDO} chmod -R u+rwX ~
	# ${SUDO} chmod og+rX ~
	# ${SUDO} chmod -R og+rX ~/Public
	# ${SUDO} chmod og=wX ~/Public/Drop\ Box
else
	${SUDO} chown $USER:$USER -Rf $HOME
fi

echo "Current user [ $USER ] has all the rights to change [ $HOME ] directory and it's file(s)."
${SUDO} chmod 0755 -Rf $HOME

echo "SSH must be with golden permission of SSH way"
${SUDO} chmod a+trwx /tmp ${HOME}/tmp
${SUDO} chmod 0700 $HOME/.ssh
${SUDO} chmod 0600 $HOME/.ssh/id_rsa*
${SUDO} chmod 0700 $HOME/.ssh/*.pub

# ssh-keygen -p -m PEM -f ~/.ssh/id_rsa
# ssh-keygen -t rsa -b 2048 -m PEM -f ~/.ssh/id_rsa

echo "[DONE] Linux home directory permission applied."

exit 0
