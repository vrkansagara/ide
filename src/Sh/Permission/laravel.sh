#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Applying application specific permissions
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

echo "Applying Laravel standard permission to local directory"

${SUDO} chown -R $USER:www-data . # Ubuntu
${SUDO} chgrp -R www-data storage bootstrap/cache
${SUDO} chmod -R ug+rwx storage bootstrap/cache

${SUDO} chmod u+x artisan

php artisan route:clear
php artisan view:clear
php artisan config:clear

echo "Laravel permission ......[DONE] "

exit 0;
