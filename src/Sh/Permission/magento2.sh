#!/usr/bin/env bash

# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

echo "Magento2 directory permission applying"
${SUDO} find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
${SUDO} find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +

${SUDO} chown -R :www-data . # Ubuntu
${SUDO} chmod u+x bin/magento

# Make code files and directories writable
${SUDO} find app/code lib var generated vendor pub/static pub/media app/etc \( -type d -or -type f \) -exec chmod g+w {} + && chmod o+rwx app/etc/env.php

echo "Magento2 permission ......[DONE] "
exit 1;
