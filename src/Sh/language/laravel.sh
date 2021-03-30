#!/usr/bin/env bash
set -e


export DEBIAN_FRONTEND=noninteractive
if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

echo "Appling Laravel standard permission to local directory"

${SUDO} chown -R $USER .
${SUDO} chgrp -R www-data storage bootstrap/cache
${SUDO} chmod -R ug+rwx storage bootstrap/cache

php artisan route:clear
php artisan view:clear
php artisan config:clear

echo "[DONE] Laravel permission reset done."
exit 0
