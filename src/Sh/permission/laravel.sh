#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive
if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

echo "Laravel directory permission applying"

${SUDO} chgrp -R www-data storage bootstrap/cache
${SUDO} chmod -R ug+rwx storage bootstrap/cache
${SUDO} chown -R :www-data . # Ubuntu
${SUDO} chmod u+x artisan

php artisan route:clear
php artisan view:clear
php artisan config:clear

echo "Laravel permission ......[DONE] "
exit 1;
