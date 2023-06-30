#!/usr/bin/env bash
#set -x # You refer to a noisy script.(Used to debugging)
set -e # This setting is telling the script to exit on a command error.
#shopt -s extglob

#PWD="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd $PWD

export OK=0
export WARNING=1
export CRITICAL=2
export UNKNOWN=3
export GREEN=$'\e[0;32m'
export RED=$'\e[0;31m'
export NC=$'\e[0m'
export host=$(hostname)
export ARCH=$(uname -m)
export KERNEL_STRING=$(uname -r | sed -e 's/[^0-9]/ /g')
export KERNEL_VERSION=$(echo "${KERNEL_STRING}" | awk '{ print $1 }')
export MAJOR_VERSION=$(echo "${KERNEL_STRING}" | awk '{ print $2 }')
export MINOR_VERSION=$(echo "${KERNEL_STRING}" | awk '{ print $3 }')
export DEBIAN_FRONTEND=noninteractive

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

if [ "$(whoami)" != "root" ]; then
  SUDO=sudo
fi

if [ $? -ne 0 ]; then
  echo "This script require GNU bc, cf. http://www.gnu.org/software/bc/"
  echo "On Linux Debian/Ubuntu you can install it by doing : apt-get install bc"
fi

# Check weather the command is exists or not.
command_exists() {
  # @note : Check if sudo is installed
  # @usage : command_exists sudo || return 1
  # @usage
  #    command_exists "$1" || {
  #        printf 'Command not found : %s\n' "$1" >&2
  #        printf 'Help : https://command-not-found.com/%s \n' "$1" >&2
  #        exit 1
  #    }
  command -v "$@" >/dev/null 2>&1
}

update_upgrade() {
  # Lets remove all apt cached list
  if [ -d "/var/lib/apt/lists" ]; then
    ${SUDO} find /var/lib/apt/lists/ -type f -delete
    ${SUDO} find /var/lib/apt/lists/ -type d -delete
  fi

  ${SUDO} touch /etc/apt/apt.conf.d/99force-ipv4
  # User rules for ubuntu (only tee - replace file)
  echo 'Acquire::ForceIPv4 "true";' | ${SUDO} tee /etc/apt/apt.conf.d/99force-ipv4

  #  ${SUDO} touch /etc/apt/apt.conf.d/99force-ipv6
  # User rules for ubuntu (only tee - replace file)
  #  echo 'Acquire::ForceIPv6 "false";' | ${SUDO} tee /etc/apt/apt.conf.d/99force-ipv6

  ${SUDO} systemctl restart NetworkManager
  ${SUDO} nmcli networking off
  ${SUDO} nmcli networking on

  sleep 5

  # Inspect current date logs
  #${SUDO} grep -ir $(date "+%b %d") /var/log/syslog
  ${SUDO} apt autoremove
  ${SUDO} apt-get --yes clean
  ${SUDO} apt-get --yes autoclean
  ${SUDO} apt-get --yes --purge autoremove
  ${SUDO} apt-get update --yes --no-install-recommends
  ${SUDO} apt-get upgrade --yes -v
  # ${SUDO} apt upgrade --yes --no-install-recommends -v
  # echo "Acquire::Languages "none";" | ${SUDO} tee -a /etc/apt/apt.conf.d/00aptitude
  # https://itectec.com/ubuntu/ubuntu-install-cgconfig-in-ubuntu-16-04/
}
backup() {
  backupDirectory="$HOME/Documents/backup"
  mkdir -p backupDirectory

  ${SUDO} sysctl --all >$HOME/Documents/backup/sysctl-${CURRENT_DATE}.txt

  ls -lA $backupDirectory
}

firewall() {
  ${SUDO} ufw deny 22/tcp
  ${SUDO} ufw allow https
  ${SUDO} ufw allow http
  ${SUDO} ufw allow ssh
  ${SUDO} ufw allow dns
  ${SUDO} ufw default allow outgoing
  ${SUDO} ufw default deny incoming
  ${SUDO} ufw reload

}

permission() {
  # Give *.sh to execute permission for the working directory
  ${SUDO} find -name '*.sh' -exec ls -lA {} +
  ${SUDO} find -name '*' -exec ls -lA {} +
}

clear_page_cache_and_swap() {
  echo "$GREEN Page cache clear started $NC"
  # 1. Clear PageCache only.
  # 2. Clear dentries and inodes.
  # 3. Clear PageCache, dentries and inodes.
  # Note, we are using "echo 3", but it is not recommended in production instead
  # use "echo 1"
  # Writing to this will cause the kernel to drop clean caches, as well as
  # reclaimable slab objects like dentries and inodes.  Once dropped, their
  # memory becomes free.
  # ${SUDO} echo "echo 3 > /proc/sys/vm/drop_caches"
  # ${SUDO} sysctl vm.drop_caches=3
  # https://www.linuxatemyram.com/
  # https://askubuntu.com/questions/155768/how-do-i-clean-or-disable-the-memory-cache
  sync && echo 3 | ${SUDO} tee /proc/sys/vm/drop_caches

  # Clear Swap Space in Linux?
  ${SUDO} swapoff -a && ${SUDO} swapon -a
}

clear_system_cache() {
  # Clear program cache/remove
  ${SUDO} rm -rfv ~/.cache/thumbnails
  ${SUDO} rm -rfv ~/.cache/mozilla
  # ${SUDO} rm -rfv ~/.mozilla

  # Find Firefox profile directory
  firefoxCacheDirectory=$(ls -d ~/.cache/mozilla/firefox/*.default* | awk '{print $NF}')
  if [[ -z "$firefoxCacheDirectory" ]]; then
    echo "$RED Removing cache from $firefoxCacheDirectory $NC"
    #    ${SUDO} rm -rfv $firefoxCacheDirectory*
  fi

  #  ${SUDO} rm -rfv ~/.config/google-chrome
  #  ${SUDO} rm -rfv ~/.cache/google-chrome

  #  ${SUDO} rm -rfv ~/.local/share/keyrings
  # cp -r -v ~/.config/google-chrome ~/.config/google-chromebackup
}

optimize_systemctl() {
  # cat /proc/meminfo | grep -E 'MemTotal:' | awk -F: '{print $2}'| sed 's/^ *//'
  totalRam=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
  totalAvailableRam=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
  totalSwap=$(awk '/SwapTotal/ {print $2}' /proc/meminfo)

  echo "Total RAM in kb is $totalRam"
  echo "Total Available RAM in kb is $totalAvailableRam"
  echo "Total Swap in kb is $totalSwap"

  # Calculate 5% of total RAM in kilobytes
  fivePercentOfRam=$(echo "scale=0; ($totalRam * 0.05 + 0.5)/1" | bc)
  tenPercentOfRam=$(echo "scale=0; ($totalRam * 0.1 + 0.5)/1" | bc)
  fifteenPercentOfRam=$(echo "scale=0; ($totalRam * 0.15 + 0.5)/1" | bc)
  fifteenPercentOfRam=$(echo "scale=0; ($totalRam * 0.15 + 0.5)/1" | bc)
  ninetyPercentOfRam=$(echo "scale=0; ($totalRam * 0.90 + 0.5)/1" | bc)
  #fivePercentOfRam=$(( ($totalRam * 5 + 99) / 100 ))
  #tenPercentOfRam=$(( ($totalRam * 10 + 99) / 100 ))
  #fifteenPercentOfRam=$(( ($totalRam * 15 + 99) / 100 ))

  #  echo "5% of Total RAM: $fivePercentOfRam KB"
  #  echo "10% of Total RAM: $tenPercentOfRam KB"
  #  echo "15% of Total RAM: $fifteenPercentOfRam KB"
  #  exit

  #set ulimit to 2 GB for current user
  #ulimit -u unlimited
  # ${SUDO} ulimit -v 2048000 # 2 GB for current user
  # ${SUDO} ulimit -v 4096000 # 4 GB for current user
  # ${SUDO} ulimit -v 8192000 # 8 GB for current user
  #ulimit -v 12582912 # 12 GB for current user
  ulimit -v $ninetyPercentOfRam # 90% of RAM

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
  #${SUDO} sysctl -n vm.vfs_cache_pressure
  ${SUDO} sysctl -w vm.vfs_cache_pressure=50

  # OOM (Out of Memory) Default = 0, Redis=1
  ${SUDO} sysctl -w vm.overcommit_memory=0

  # Print default value
  # vm.dirty_background_ratio=10
  # vm.dirty_ratio=20
  #${SUDO} sysctl -n vm.dirty_background_ratio
  ${SUDO} sysctl -w vm.dirty_background_ratio=20
  #${SUDO} sysctl -w vm.dirty_ratio=10
  # Keep at least 128MB of free RAM space available
  #${SUDO} sysctl -n vm.min_free_kbytes
  #  ${SUDO} sysctl -w vm.min_free_kbytes=128000
  ${SUDO} sysctl -w vm.min_free_kbytes=$fivePercentOfRam

  # Native file system watcher for Linux
  #cat /proc/sys/fs/inotify/max_user_watches
  # ${SUDO} sysctl -w fs.inotify.max_user_watches=524288
  ${SUDO} sysctl -w fs.inotify.max_user_watches=1048576

  #  ${SUDO} sysctl -w net.ipv6.conf.all.disable_ipv6=0
  #  ${SUDO} sysctl -w net.ipv6.conf.default.disable_ipv6=0
  #  ${SUDO} sysctl -w net.ipv6.conf.lo.disable_ipv6=0
  #  net.ipv6.conf.wlan0.disable_ipv6 = 1

  # dmesg: read kernel buffer failed: Permission denied
  ${SUDO} sysctl kernel.dmesg_restrict=0

  #  ${SUDO} cat /proc/sys/kernel/printk
  #4	4	1	7 ( Default )

  # helpful into kernel development
  ${SUDO} sh -c "echo 7 4 1 7 > /proc/sys/kernel/printk"

  # Clean up dmesg
  # ${SUDO} dmesg -C

  # sysctl - configure kernel parameters at runtime
  # ${SUDO} sysctl -p
  ${SUDO} sysctl -p --system
  ${SUDO} systemctl restart procps
  ${SUDO} systemctl restart NetworkManager
  ${SUDO} nmcli networking off
  ${SUDO} nmcli networking on

}

debug() {
  # Finally check with system log if any process is out of memory
  ${SUDO} dmesg -H --color | grep -i -E 'error|warn|failed'
  ${SUDO} grep --color -i -r 'out of memory' /var/log/
  ${SUDO} grep -color -i -r 'error' /var/log/syslog | grep -v 'containerd'
}

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :- This is standard linux tune up script
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

optimize_systemctl
#backup
#firewall
permission
#clear_page_cache_and_swap
#clear_system_cache
update_upgrade

#echo "Linux kernel is $GREEN ${KERNEL_VERSION}.${MAJOR_VERSION}.${MINOR_VERSION} $NC"
#
#echo "List of Available Processors:"
#echo "-----------------------------"
#
#lscpu | grep -E "Model name|Socket|Core\(s\) per socket|Thread\(s\) per core" | awk -F: '{print $2}' | sed 's/^ *//'
#
exit

#Disabling Transparent Huge Pages (THP) (Default(madvise) :- always [madvise] never)
# Default :- madvise , Redis :- never
# madvise = To prevent applications from allocating more memory resources than necessary,
# you can disable huge pages system-wide and only enable them inside MADV_HUGEPAGE madvise regions by running:
# never = To disable transparent huge pages
# always = To enable transparent huge pages
${SUDO} cat /sys/kernel/mm/transparent_hugepage/enabled

#${SUDO} apt install --no-install-recommends --yes --reinstall gnome-control-center
${SUDO} apt install --no-install-recommends --yes zsh zsh-autosuggestions zsh-common zsh-syntax-highlighting
# inxi -Fxz
${SUDO} apt install --no-install-recommends --yes lm-sensors inxi mlocate

${SUDO} apt-get install -qq --no-install-recommends --yes default-jre default-jdk procps preload tlp tlp-rdw preload
# https://www.ccnahub.com/linux/applying-system-and-network-tuneup-rules/
# Required software to tuneup :- sudo apt-get install tlp tlp-rdw preload
${SUDO} systemctl enable tlp.service
${SUDO} tlp start
# tlp tlp-rdw = TLP which helps in cooling down your system and making it run faster and smoother.
# First thing First

# https://gist.github.com/juanje/9861623
# ${SUDO} apt-get install cgroup-tools cgroup-lite cgroup-tools cgroupfs-mount libcgroup1

#Stoping unwanted services
${SUDO} systemctl stop bluetooth
#${SUDO} systemctl stop virtualbox
#${SUDO} systemctl stop mongodb
#${SUDO} systemctl stop postgresql
#${SUDO} systemctl stop mosquitto
#${SUDO} systemctl stop php5.6-fpm
#${SUDO} systemctl stop php7.4-fpm
#${SUDO} systemctl stop php8.0-fpm
#${SUDO} systemctl stop gdm3
#${SUDO} systemctl stop remotely-agent.service
#${SUDO} systemctl stop ufw
# ${SUDO} systemctl disable ufw bluetooth virtualbox mongodb mosquitto postgresql.service
# ${SUDO} systemctl stop qhclagnt qhdevdmn qhscheduler qhscndmn qhwebsec quickupdate whoopsie
${SUDO} service --status-all | grep +
# ${SUDO} sudo systemd-analyze blame

${SUDO} lshw -c memory
# Print virtual memory status
# ${SUDO} vmstat -sS M

# Clean up journalctl (Free up some space) , glibc-source, glibc-tools
# apt install openafs-client
# https://access.redhat.com/solutions/1450043
# https://packages.ubuntu.com/focal/amd64/kernel/linux-image-unsigned-5.14.0-1054-oem
# ${SUDO} journalctl --vacuum-size=500M
# Clean up old journal older then 30 day
${SUDO} journalctl --vacuum-time=3d
# List all boots ( journalctl --list-boots )
# Check last boot logs ( journalctl -b -1 -e / journalctl -k -b -1 )

# You only need to delete files with “.log” extension and modified before 3 days
if [ -f "/var/log/nginx" ]; then
  ${SUDO} find /var/log/nginx -type f -mtime +3 -delete
fi

#Clean up phpmd logs
${SUDO} find $HOME/.pdepend -type f -mtime +3 -delete
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

if ! command -v earlyoom &>/dev/null; then
  ${SUDO} apt install earlyoom
  # EARLYOOM_ARGS="-m 5 -r 60 --avoid '(^|/)(init|Xorg|ssh)$' --prefer '(^|/)(java|chromium|google-chrome|skype|teams)$'"
fi

# Remove old phpstome directories.
# rm -rf  ~/.config/JetBrains ~/.local/share/JetBrains  ~/.cache/JetBrains ~/.cache/JetBrains
# rm -rf ~/.local/share/JetBrains/consentOptions
# rm -rf ~/.java/.userPrefs

# Restart or bug fix of apt system
gpgconf --kill gpg-agent

#killall gpg-agent

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
  ${SUDO} cp /etc/sysctl.d/local.conf $HOME/Documents/backup/sysctl-local-${CURRENT_DATE}.conf
fi

#echo '
## Kernel system variables configuration files
## My personal preference
#vm.swappiness=80
#vm.vfs_cache_pressure=200
#vm.overcommit_memory=0
#vm.overcommit_ratio=50
#vm.dirty_background_ratio=10
#vm.dirty_ratio=20
#vm.min_free_kbytes=128000
#fs.inotify.max_user_watches=1048576
#net.ipv6.conf.all.disable_ipv6=0
#net.ipv6.conf.default.disable_ipv6=0
#net.ipv6.conf.lo.disable_ipv6=0
#kernel.dmesg_restrict=0
#' | ${SUDO} tee /etc/sysctl.d/local.conf > /dev/null

#${SUDO} sysctl -w net.ipv6.conf.all.disable_ipv6=1
#${SUDO} sysctl -w net.ipv6.conf.default.disable_ipv6=1
#${SUDO} sysctl -w net.ipv6.conf.lo.disable_ipv6=1
# /etc/sysctl.d/98-mld_grv.conf
#${SUDO} sysctl -w net.ipv6.mld_qrv=1

echo "Tune of system is ....... [DONE]"
echo "Updating [updatedb] ....... [Running]"

firefox() {
  # Clear dns cache
  #(1)  about:networking#dns
  # (2) Clear
  # (3) about:configfiref
  #network.dnsCacheEntries
  #network.dnsCacheExpiration
  #network.dnsCacheExpirationGracePeriod
  ls -lA
}

# https://klaver.it/linux/sysctl.conf
# https://people.redhat.com/alikins/system_tuning.html#tcp
# https://cromwell-intl.com/open-source/performance-tuning/nfs.html
exit 0

#echo "tmpfs /tmp tmpfs rw,nosuid,nodev" | sudo tee -a /etc/fstab
#echo "tmpfs /var/tmp tmpfs rw,nosuid,nodev" | sudo tee -a /etc/fstab
#echo "tmpfs /var/log/journal tmpfs rw,nosuid,nodev" | sudo tee -a /etc/fstab
#echo "tmpfs /home/vallabh/.pdepend tmpfs rw,nosuid,nodev" | sudo tee -a /etc/fstab
#sudo reboot
