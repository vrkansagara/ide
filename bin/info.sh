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

rm -rfv ~/.cache/thumbnails
# cp -r -v ~/.mozilla ~/.mozillabackup
# cp -r -v ~/.config/google-chrome ~/.config/google-chromebackup
# /etc/sysctl.conf
# sudo cat /proc/sys/vm/swappiness
# sudo cat /proc/sys/vm/vfs_cache_pressure
# vm.swappiness=10
# vm.vfs_cache_pressure=50

# sudo sysctl -w vm.swappiness=10
# sudo sysctl -w vm.vfs_cache_pressure=50


# find -name '*.sh' -exec ls -lA {} +
