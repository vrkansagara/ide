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
#  Note       :- Install swoole from source
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt install git libc-ares-dev --yes --no-install-recommends php-pear build-essential libbrotli-dev \
libpcre3 libpcre3-dev openssl libssl-dev procps libcurl4-openssl-dev libnghttp2-dev nghttp2 libpq-dev \
libbsd-dev libmd-dev
# https://github.com/openswoole/swoole-src

cd /tmp
git clone https://github.com/openswoole/swoole-src.git --depth=1 --branch v4.12.0
cd swoole-src

${SUDO} make clean
git clean -fd
git reset --hard HEAD

sudo make clean &&
phpize &&
  ./configure \
    --enable-openssl \
    --enable-sockets \
    --enable-http2 \
    --enable-mysqlnd \
    --enable-swoole-json \
    --with-postgres \
    --enable-cares \
    --enable-swoole-curl

${SUDO} make
${SUDO} make install
${SUDO} bash -c "echo 'extension=curl' >> $(php -i | grep /.+/php.ini -oE)"
${SUDO} bash -c "echo 'extension=openswoole' >> $(php -i | grep /.+/php.ini -oE)"
${SUDO} make test

php --ri openswoole

# libtool: install: cp ./.libs/swoole.so /home/vallabh/tmp/swoole-src/modules/swoole.so
# libtool: install: cp ./.libs/swoole.lai /home/vallabh/tmp/swoole-src/modules/swoole.la
# libtool: finish: PATH="..." ldconfig -n /home/vallabh/tmp/swoole-src/modules
# Libraries have been installed in: /home/vallabh/tmp/swoole-src/modules
# Build complete. Don't forget to run 'make test'.



echo "swoole.sh installatiuon .....[DONE]"

exit 0
