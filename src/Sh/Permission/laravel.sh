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

exit 0
