#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

echo "$USER is the only one is owning the $HOME directory"
${SUDO} chown $USER:$USER -Rf $HOME

echo "$USER has all the rights to change $HOME directory"
${SUDO} chmod 0755 -Rf $HOME

echo "SSH must be with golden permission of SSH way"
${SUDO} chmod 0700 $HOME/.ssh
${SUDO} chmod 0600 $HOME/.ssh/id_rsa*
${SUDO} chmod 0700 $HOME/.ssh/*.pub

echo "[DONE] Linux home directory permission applied."

exit 0
