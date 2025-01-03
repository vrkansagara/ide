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
#  Note       :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt-get autoremove
${SUDO} apt-get install -f

${SUDO} apt install --no-install-recommends --yes \
  apt-transport-https lsb-release ca-certificates curl \
  software-properties-common php-pear

if [ -n "$(uname -a | grep -i 'Ubuntu\|WSL')" ]; then
  ${SUDO} add-apt-repository --yes ppa:ondrej/php
else
  ${SUDO} curl -sSL -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
  ${SUDO} sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
  ${SUDO} apt-get update
fi

for VERSION in 7.4 8.0 8.1 8.2 8.3 8.4; do
  for EXTENSION in dev fpm memcached exif soap bcmath ctype fileinfo mbstring pdo phar simplexml tokenizer xml xmlwriter curl dom intl gd gmp imagick mysqli zip xdebug curl; do
    ${SUDO} apt-get install --no-install-recommends --yes php${VERSION}-${EXTENSION}
  done
done

# ${SUDO} pecl install --configureoptions 'enable-sockets="no" enable-openssl="yes" enable-http2="yes" enable-mysqlnd="yes" enable-swoole-json="no" enable-swoole-curl="yes" enable-cares="yes" with-postgres="yes"' openswoole

${SUDO} update-alternatives --config php

echo "php-installation.sh ..... [DONE]"

exit 0
