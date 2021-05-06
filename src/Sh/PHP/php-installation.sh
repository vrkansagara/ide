#!/usr/bin/env bash

# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)
export DEBIAN_FRONTEND=noninteractive

if [ "(whoami)" != "root" ]; then
	SUDO=sudo
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
${SUDO} apt install software-properties-common
${SUDO} add-apt-repository ppa:ondrej/php
${SUDO} apt update

for VERSION in 7.4 8.0;do
    for EXTENSION in fpm memcached exif soap bcmath ctype fileinfo json mbstring pdo phar simplexml tokenizer xml xmlwriter curl dom intl gd gmp imagick mysqli zip xdebug;do
        ${SUDO} apt install php${VERSION}-${EXTENSION} -y
    done
done

echo "[DONE] php-installation.sh"

exit 1
