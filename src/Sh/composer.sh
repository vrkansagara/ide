#!/usr/bin/env bash
set -e

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

mv composer.phar composer
${SUDO} mv composer /usr/local/bin


composer global require --dev roave/security-advisories:dev-latest
composer global require friendsofphp/php-cs-fixer
composer global require laminas/laminas-migration
composer global require laravel/installer

composer global update -vvv
echo "Composer installation done with global package installation [DONE]."
