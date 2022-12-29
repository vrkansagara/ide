#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

echo " "
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
  SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Init script
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt-get install neofetch unzip git  --yes --no-install-recommends

cd /tmp
${SUIDO} rm -rf /tmp/jq $(pwd)/bin/jq
wget https://github.com/stedolan/jq/releases/latest/download/jq-linux64 -O jq
chmod +x /tmp/jq
echo '{"foo": 0}' | /tmp/jq .
mv /tmp/jq $(pwd)/bin


cd /tmp
${SUIDO} rm -rf /tmp/JMESPath $(pwd)/bin/JMESPath
wget https://github.com/jmespath/jp/releases/latest/download/jp-linux-amd64 -O JMESPath
chmod +x /tmp/JMESPath
echo '{"a": "foo", "b": "bar", "c": "baz"}' | /tmp/JMESPath a
mv /tmp/JMESPath $(pwd)/bin

${SUDO} chmod +x $HOME/.vim/bin/*

# Run command at vim and exit
vim -c 'PlugInstall|q'
vim -c 'PlugUpdate|q'
vim -c 'PlugClean|q'
vim -c 'PlugUpgrade|q'


composer self-update
rm -rf composer.phar
rm -rf vendor composer.lock
composer update
./vendor/bin/grumphp  git:init
./vendor/bin/grumphp  git:deinit
./vendor/bin/grumphp
./vendor/bin/composer install --prefer-dist --no-scripts --no-progress --no-interaction --no-dev
${SUDO} npm i -g npm@latest intelephense@latest livereloadx yarn
yarn set version latest

# update coc-nvim plugines
#echo "Wait for 2 minutes, coc-nvim plugines is started updating"
#vim -c 'CocUpdateSync|q'
#echo "Add intelephense license here"
#node -e "console.log(os.homedir() + '/intelephense/licence.txt')"

