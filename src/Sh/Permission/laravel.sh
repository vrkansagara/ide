#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive
if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

echo "Appling Laravel standard permission to local directory"

${SUDO} chown -R $USER:www-data . # Ubuntu
${SUDO} chgrp -R www-data storage bootstrap/cache
${SUDO} chmod -R ug+rwx storage bootstrap/cache

${SUDO} chmod u+x artisan

php artisan route:clear
php artisan view:clear
php artisan config:clear

echo "Laravel permission ......[DONE] "

exit 1;
