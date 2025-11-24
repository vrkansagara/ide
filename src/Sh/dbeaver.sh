#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
	shift
fi

export  CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# DEBIAN
# wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
# echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
# sudo apt-get update && sudo apt-get install dbeaver-ce
# wget -k https://dbeaver.com/files/dbeaver-ee-latest-linux.gtk.x86_64.tar.gz -O $HOME/Applications/dbeaver-ee-latest-linux.gtk.x86_64.tar.gz

#sudo snap connect dbeaver-ce:ssh-key
#sudo snap connect dbeaver-ce:ssh-public-keys
#
#${SUDO} add-apt-repository ppa:serge-rider/dbeaver-ce
#${SUDO} apt-get update
#${SUDO} apt-get install dbeaver-ce
