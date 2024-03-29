#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

echo
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Composer installation script.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if ! command -v composer &>/dev/null; then
	echo "composer command not found"
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
	php composer-setup.php
	php -r "unlink('composer-setup.php');"

	mv composer.phar composer
	${SUDO} mv composer /usr/local/bin
fi

composer global require --dev roave/security-advisories:dev-latest
composer global require --dev phpro/grumphp
composer global require --dev friendsofphp/php-cs-fixer
composer global require laminas/laminas-migration
composer global require laravel/installer

composer global update -v

echo "Composer installation done with global package installation [DONE]."

exit 0
