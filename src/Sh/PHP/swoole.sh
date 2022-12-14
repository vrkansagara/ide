#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

echo ""
export DEBIAN_FRONTEND=noninteractive
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
SCRIPT=$(readlink -f "")
SCRIPTDIR=$(dirname "$SCRIPT")

if [ "$(whoami)" != "root" ]; then
SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :- Install swoole from source
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt install git libc-ares-dev --yes --no-install-recommends
cd /tmp 
git clone https://github.com/openswoole/swoole-src.git --depth=1 --branch 4.8.1
cd swoole-src

${SUDO} make clean
git clean -fd
git reset --hard HEAD

phpize  && \
            ./configure --enable-openssl \
            --enable-mysqlnd \
            --enable-sockets \
            --enable-http2 \
            --enable-swoole-curl \
            --enable-swoole-json \
            --enable-cares

            # --with-postgres \
${SUDO} make
${SUDO} make install
${SUDO} bash -c "echo 'extension=openswoole' >> $(php -i | grep /.+/php.ini -oE)"
${SUDO} make test

php --ri openswoole

echo "swoole.sh installatiuon .....[DONE]"

exit 0
