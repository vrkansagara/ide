#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

for VERSION in 7.4;do
    for EXTENSION in fpm memcached exif soap bcmath ctype fileinfo json mbstring pdo phar simplexml tokenizer xml xmlwriter curl dom intl gd gmp imagick mysqli zip xdebug;do
        ${SUDO} apt install php${VERSION}-${EXTENSION} -y
    done
done

echo "[DONE] php-installation.sh"

exit 0
