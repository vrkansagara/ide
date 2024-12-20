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
#  Note		  :- MySQL Reset root password
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

sudo mysql -u root
DROP USER 'root'@'localhost'
CREATE USER 'root'@'%' IDENTIFIED BY 'toor'
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION
FLUSH PRIVILEGES
mysql -u root
