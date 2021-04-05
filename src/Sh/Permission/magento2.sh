#!/usr/bin/env bash
set -e

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")


if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi



echo "Magento2 directory permission applying"
${SUDO} find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
${SUDO} find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
${SUDO} chown -R :www-data . # Ubuntu
${SUDO} chmod u+x bin/magento

echo "Magento2 permission ......[DONE] "
exit 1;
