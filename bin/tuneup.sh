#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo " "
export DEBIAN_FRONTEND=noninteractive
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
SCRIPT=$(readlink -f "")
SCRIPTDIR=$(dirname "$SCRIPT")

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi
cd $SCRIPTDIR

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :- This is standard linux tune up script
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


 # 1. Clear PageCache only.
 # 2. Clear dentries and inodes.
 # 3. Clear PageCache, dentries and inodes.
 # Note, we are using "echo 3", but it is not recommended in production instead
 # use "echo 1"
 # Writing to this will cause the kernel to drop clean caches, as well as
 # reclaimable slab objects like dentries and inodes.  Once dropped, their
 # memory becomes free.
 # ${SUDO} echo "echo 3 > /proc/sys/vm/drop_caches"
 ${SUDO} sysctl vm.drop_caches=3

# Clear Swap Space in Linux?
# ${SUDO}  swapoff -a && ${SUDO} swapon -a
${SUDO}  swapoff -a && ${SUDO} swapon -a

${SUDO} rm -rfv ~/.cache/thumbnails
# ${SUDO} rm -rfv ~/.mozilla
# ${SUDO} rm -rfv ~/.cache/mozilla
# ${SUDO} rm -rfv ~/.config/google-chrome
# cp -r -v ~/.config/google-chrome ~/.config/google-chromebackup
# /etc/sysctl.conf

# swappiness
# This control is used to define how aggressive the kernel will swap
# memory pages.  Higher values will increase aggressiveness, lower values
# decrease the amount of swap.  A value of 0 instructs the kernel not to
# initiate swap until the amount of free and file-backed pages is less
# than the high water mark in a zone.
# The default value is 60.
${SUDO} sysctl -w vm.swappiness=10

# This percentage value controls the tendency of the kernel to reclaim
# the memory which is used for caching of directory and inode objects (Default
# =100)
# vfs_cache_pressure – Controls the kernel’s tendency to reclaim the memory,
# which is used for caching of directory and inode objects. (default = 100,
# recommend value 50 to 200)
${SUDO} sysctl -n vm.vfs_cache_pressure
${SUDO} sysctl -w vm.vfs_cache_pressure=200

# Print default value
# vm.dirty_background_ratio=10
# vm.dirty_ratio=20
${SUDO} sysctl -n vm.dirty_background_ratio
${SUDO} sysctl -w vm.dirty_background_ratio=20

# Native file system watcher for Linux
cat /proc/sys/fs/inotify/max_user_watches
${SUDO} sysctl -w fs.inotify.max_user_watches = 524288

${SUDO} sysctl -w net.ipv6.conf.all.disable_ipv6 = 1
${SUDO} sysctl -w net.ipv6.conf.default.disable_ipv6 = 1
${SUDO} sysctl -w net.ipv6.conf.lo.disable_ipv6 = 1

${SUDO} sysctl -p


#set ulimit to 2 GB for current user
# ulimit -v 2048000
${SUDO} ulimit -v 12582912 # 12 GB for current user
# ${SUDO} ulimit -v 8192000 # 8 GB for current user
# ${SUDO} ulimit -v 4096000 # 4 GB for current user

# find -name '*.sh' -exec ls -lA {} +
# https://gist.github.com/juanje/9861623
#clear up system cache
# ${SUDO} apt install default-jre default-jdk --no-install-recommends
# ${SUDO} apt install --reinstall --no-install-recommends gnome-control-center
# ${SUDO} apt-get install cgroup-tools cgroup-lite cgroup-tools cgroupfs-mount libcgroup1

#Stoping unwanted services

${SUDO} systemctl stop  bluetooth
${SUDO} systemctl stop  virtualbox
${SUDO} systemctl stop  mongodb
${SUDO} systemctl stop  postgresql
${SUDO} systemctl stop  mosquitto
${SUDO} systemctl stop  php8.0-fpm
# ${SUDO} systemctl stop  ufw
${SUDO} systemctl disable ufw bluetooth virtualbox mongodb mosquitto postgresql.service
${SUDO} service --status-all | grep +

# Finally check with system log if any process is out of memory
${SUDO} grep -i -r 'out of memory' /var/log/
${SUDO} lshw -c memory
${SUDO} apt-get install procps preload --no-install-recommends
# Print virtual memory status
# ${SUDO} vmstat -sS M

# Inspect current date logs
# ${SUDO} grep -ir $(date "+%b %d") /var/log/syslog
${SUDO} apt autoremove
${SUDO} apt-get --yes clean
${SUDO} apt-get --yes autoclean
${SUDO} apt-get --yes --purge  autoremove
${SUDO} apt-get update --yes --no-install-recommends
${SUDO} apt-get upgrade --yes -v
# ${SUDO} apt upgrade --yes --no-install-recommends -v
# echo "Acquire::Languages "none";" | ${SUDO} tee -a /etc/apt/apt.conf.d/00aptitude
# https://itectec.com/ubuntu/ubuntu-install-cgconfig-in-ubuntu-16-04/

# Clean up journalctl (Free up some space)
# journalctl --vacuum-size=500M
${SUDO} journalctl --vacuum-time=30d

# You only need to delete files with “.log” extension and modified before 3 days
${SUDO} find /var/log/nginx -type f -mtime +3 -delete
${SUDO} find /var/log -name "*.log" -type f -mtime +3 -delete
${SUDO} find /var/log -name "*.log.*" -type f -mtime +3 -delete
${SUDO} find /var/log -type f -regex ".*\.gz$" -delete
${SUDO} find /var/log -type f -regex ".*\.[0-9]$" -delete

# Clean up dmesg
# dmesg: read kernel buffer failed: Permission denied
${SUDO} sysctl kernel.dmesg_restrict=0
${SUDO} dmesg -C

# Clean up old journal older then 2 day
# journalctl --vacuum-size=500M
${SUDO} journalctl --vacuum-time=2d

if ! command -v earlyoom &> /dev/null
then
    ${SUDO} apt install earlyoom
    # EARLYOOM_ARGS="-m 5 -r 60 --avoid '(^|/)(init|Xorg|ssh)$' --prefer '(^|/)(java|chromium|google-chrome|skype|teams)$'"
fi

# Remove old phpstome directories.
# rm -rf  ~/.config/JetBrains ~/.local/share/JetBrains  ~/.cache/JetBrains ~/.cache/JetBrains
# rm -rf ~/.local/share/JetBrains/consentOptions
# rm -rf ~/.java/.userPrefs

# Restart or bug fix of apt system
gpgconf --kill gpg-agent

echo "Tune of system is ....... [DONE]"
exit 0
