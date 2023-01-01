#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

echo " "
export DEBIAN_FRONTEND=noninteractive
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :- This is standard linux tune up script
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# First thing First

${SUDO} sysctl --all > $HOME/Documents/sysctl-${CURRENT_DATE}.txt

${SUDO} ufw default allow outgoing
${SUDO} ufw default deny incoming

# Give *.sh to execute permission for the working directory
${SUDO} find -name '*.sh' -exec ls -lA {} +

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

# Clear program cache/remove
${SUDO} rm -rfv ~/.cache/thumbnails
# ${SUDO} rm -rfv ~/.mozilla
# ${SUDO} rm -rfv ~/.cache/mozilla
# ${SUDO} rm -rfv ~/.config/google-chrome
# cp -r -v ~/.config/google-chrome ~/.config/google-chromebackup
# /etc/sysctl.conf

# Clear Swap Space in Linux?
${SUDO}  swapoff -a && ${SUDO} swapon -a

# swappiness
# This control is used to define how aggressive the kernel will swap
# memory pages.  Higher values will increase aggressiveness, lower values
# decrease the amount of swap.  A value of 0 instructs the kernel not to
# initiate swap until the amount of free and file-backed pages is less
# than the high water mark in a zone.
# The default value is 60.
# For redis instance it should be 1
${SUDO} sysctl -w vm.swappiness=10

# This percentage value controls the tendency of the kernel to reclaim
# the memory which is used for caching of directory and inode objects (Default
# =100)
# vfs_cache_pressure – Controls the kernel’s tendency to reclaim the memory,
# which is used for caching of directory and inode objects. (default = 100,
# recommend value 50 to 200)
${SUDO} sysctl -n vm.vfs_cache_pressure
${SUDO} sysctl -w vm.vfs_cache_pressure=200

# OOM (Out of Memory) Default = 0, Redis=1
${SUDO} sysctl -w vm.overcommit_memory=0

# Print default value
# vm.dirty_background_ratio=10
# vm.dirty_ratio=20
${SUDO} sysctl -n vm.dirty_background_ratio
${SUDO} sysctl -w vm.dirty_background_ratio=5
${SUDO} sysctl -w vm.dirty_ratio=10
# Keep at least 128MB of free RAM space available
${SUDO} sysctl -w vm.min_free_kbytes=128000

# Native file system watcher for Linux
cat /proc/sys/fs/inotify/max_user_watches
${SUDO} sysctl -w fs.inotify.max_user_watches=524288
${SUDO} sysctl -w fs.inotify.max_user_watches=1048576

${SUDO} sysctl -w net.ipv6.conf.all.disable_ipv6=0
${SUDO} sysctl -w net.ipv6.conf.default.disable_ipv6=0
${SUDO} sysctl -w net.ipv6.conf.lo.disable_ipv6=0

# Clean up dmesg
# dmesg: read kernel buffer failed: Permission denied
${SUDO} sysctl kernel.dmesg_restrict=0
${SUDO} dmesg -C

# sysctl - configure kernel parameters at runtime
# ${SUDO} sysctl -p

#Disabling Transparent Huge Pages (THP) (Default(madvise) :- always [madvise] never)
# Default :- madvise , Redis :- never
# madvise = To prevent applications from allocating more memory resources than necessary, you can disable huge pages system-wide and only enable them inside MADV_HUGEPAGE madvise regions by running:
# never = To disable transparent huge pages
# always = To enable transparent huge pages
${SUDO} cat /sys/kernel/mm/transparent_hugepage/enabled

#set ulimit to 2 GB for current user
# ${SUDO} ulimit -v 2048000 # 2 GB for current user
# ${SUDO} ulimit -v 4096000 # 4 GB for current user
# ${SUDO} ulimit -v 8192000 # 8 GB for current user
${SUDO} ulimit -v 12582912 # 12 GB for current user

${SUDO} apt install --no-install-recommends --yes default-jre default-jdk
#${SUDO} apt install --no-install-recommends --yes --reinstall gnome-control-center
#${SUDO} apt install --no-install-recommends --yes --reinstall zsh zsh-autosuggestions zsh-common zsh-syntax-highlighting

# https://gist.github.com/juanje/9861623
# ${SUDO} apt-get install cgroup-tools cgroup-lite cgroup-tools cgroupfs-mount libcgroup1

#Stoping unwanted services
${SUDO} systemctl stop bluetooth
${SUDO} systemctl stop virtualbox
${SUDO} systemctl stop mongodb
${SUDO} systemctl stop postgresql
${SUDO} systemctl stop mosquitto
${SUDO} systemctl stop php5.6-fpm
${SUDO} systemctl stop php7.4-fpm
${SUDO} systemctl stop php8.0-fpm
${SUDO} systemctl stop remotely-agent.service
#${SUDO} systemctl stop ufw
# ${SUDO} systemctl disable ufw bluetooth virtualbox mongodb mosquitto postgresql.service
# ${SUDO} systemctl stop qhclagnt qhdevdmn qhscheduler qhscndmn qhwebsec quickupdate whoopsie
${SUDO} service --status-all | grep +

# Finally check with system log if any process is out of memory
${SUDO} grep --color -i -r 'out of memory' /var/log/
${SUDO} grep -i -r 'error' /var/log/syslog | grep -v 'containerd'
${SUDO} lshw -c memory
${SUDO} apt-get install procps preload --yes --no-install-recommends
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

# Clean up journalctl (Free up some space) , glibc-source, glibc-tools
# apt install openafs-client
# https://access.redhat.com/solutions/1450043
# https://packages.ubuntu.com/focal/amd64/kernel/linux-image-unsigned-5.14.0-1054-oem
# ${SUDO} journalctl --vacuum-size=500M
# Clean up old journal older then 30 day
${SUDO} journalctl --vacuum-time=3d
# List all boots ( journalctl --list-boots )
# Check last boot logs ( journalctl -b -1 -e )

# You only need to delete files with “.log” extension and modified before 3 days
${SUDO} find /var/log/nginx -type f -mtime +3 -delete
${SUDO} find /var/log -name "*.log" -type f -mtime +3 -delete
${SUDO} find /var/log -name "*.log.*" -type f -mtime +3 -delete
${SUDO} find /var/log -type f -regex ".*\.gz$" -delete
${SUDO} find /var/log -type f -regex ".*\.[0-9]$" -delete
# Clean apt history logs
if [ -f "/var/log/apt/history.log" ]; then
  ${SUDO} head -n 1 /var/log/apt/history.log | sudo tee /var/log/apt/history.log
fi
if [ -f "/var/log/apt-history.log" ]; then
  ${SUDO} head -n 1 /var/log/apt-history.log | sudo tee /var/log/apt-history.log
fi

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

${SUDO} service snapd.apparmor restart
${SUDO} systemctl enable --now apparmor.service
${SUDO} systemctl enable --now snapd.apparmor.service

echo "Max threads :"
${SUDO} cat /proc/sys/kernel/threads-max
echo "Total threads running:"
ps -eo nlwp | awk '$1 ~ /^[0-9]+$/ { n += $1 } END { print n }'


if [ -f "/etc/sysctl.d/local.conf" ]; then
  # Lets backup the resolver
  ${SUDO} cp /etc/sysctl.d/local.conf /etc/sysctl.d/local-${CURRENT_DATE}.conf
fi
echo '
# Kernel system variables configuration files
# My personal preference
vm.swappiness=80
vm.vfs_cache_pressure=200
vm.overcommit_memory=0
vm.overcommit_ratio=50
vm.dirty_background_ratio=10
vm.dirty_ratio=20
vm.min_free_kbytes=128000
fs.inotify.max_user_watches=1048576
net.ipv6.conf.all.disable_ipv6=0
net.ipv6.conf.default.disable_ipv6=0
net.ipv6.conf.lo.disable_ipv6=0
kernel.dmesg_restrict=0
' | ${SUDO} tee /etc/sysctl.d/local.conf  >/dev/null

echo "Tune of system is ....... [DONE]"

# https://klaver.it/linux/sysctl.conf
# https://people.redhat.com/alikins/system_tuning.html#tcp
# https://cromwell-intl.com/open-source/performance-tuning/nfs.html
exit 0