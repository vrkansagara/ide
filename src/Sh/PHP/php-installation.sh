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

if [  -n "$(uname -a | grep -i Ubuntu)" ]; then
    ${SUDO} add-apt-repository --yes ppa:ondrej/php
else
    ${SUDO} apt-get -y install apt-transport-https lsb-release ca-certificates curl
    ${SUDO} curl -sSL -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    ${SUDO} sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
fi 

${SUDO} apt install --no-install--recommends --yes \ 
php-pear \
software-properties-common

for VERSION in 5.5 5.6 7.4 8.0;do
	for EXTENSION in dev fpm memcached exif soap bcmath ctype fileinfo json mbstring pdo phar simplexml tokenizer xml xmlwriter curl dom intl gd gmp imagick mysqli zip xdebug curl;do
		${SUDO} apt install --no-install-recommends --yes php${VERSION}-${EXTENSION}
	done
done

# ${SUDO} pecl install --configureoptions 'enable-sockets="no" enable-openssl="yes" enable-http2="yes" enable-mysqlnd="yes" enable-swoole-json="no" enable-swoole-curl="yes" enable-cares="yes" with-postgres="yes"' openswoole

${SUDO} update-alternatives --config php

echo "php-installation.sh ..... [DONE]"

exit 0 
