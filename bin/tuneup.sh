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

 # 1. Clear PageCache only.
 # sync; echo 1 > /proc/sys/vm/drop_caches
 # sudo sysctl vm.drop_caches=1
 # 2. Clear dentries and inodes.
 # sync; echo 2 > /proc/sys/vm/drop_caches
 # sudo sysctl vm.drop_caches=2
 # 3. Clear PageCache, dentries and inodes.
 # sync; echo 3 > /proc/sys/vm/drop_caches
 # sudo sysctl vm.drop_caches=3
# Note, we are using "echo 3", but it is not recommended in production instead
# use "echo 1"
${SUDO} echo "echo 3 > /proc/sys/vm/drop_caches"

#Clear Swap Space in Linux?
${SUDO}  swapoff -a && ${SUDO} swapon -a

${SUDO} rm -rfv ~/.cache/thumbnails
${SUDO} rm -rfv ~/.mozillabackup
${SUDO} cp -r -v ~/.mozilla ~/.mozillabackup
${SUDO} rm -rfv ~/.mozilla
${SUDO} rm -rfv ~/.cache/mozilla

# https://itectec.com/ubuntu/ubuntu-install-cgconfig-in-ubuntu-16-04/
# https://gist.github.com/juanje/9861623
#clear up system cache
${SUDO} apt default-jre default-jdk cgroup-tools
${SUDO} apt update
${SUDO} apt upgrade -V
${SUDO} apt-get -y clean
${SUDO} apt-get -y autoclean
${SUDO} apt-get -y autoremove --purge

# cp -r -v ~/.config/google-chrome ~/.config/google-chromebackup
# /etc/sysctl.conf
# sudo cat /proc/sys/vm/swappiness
# sudo cat /proc/sys/vm/vfs_cache_pressure
# vm.swappiness=10
# vm.vfs_cache_pressure=50

${SUDO} sysctl -w vm.swappiness=10
${SUDO} sysctl -w vm.vfs_cache_pressure=50

#set ulimit to 2 GB for current user
ulimit -v 2048000
# find -name '*.sh' -exec ls -lA {} +


