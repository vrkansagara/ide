#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Setting up cgroup for process controll
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# /etc/fstab
# cgroup /sys/fs/cgroup cgroup defaults,blkio,net_cls,freezer,devices,cpuacct,cpu,cpuset,memory,clone_children 0 0

#Edit kernel options in /etc/default/grub:
# GRUB_CMDLINE_LINUX_DEFAULT="quiet cgroup_enable=memory,namespace"
#update-grub

# mount -t cgroup -o memory cgroup_memory /sys/fs/cgroup/memory
# And that's assuming that /sys/fs/cgroup is mounted at all.
# mount -t tmpfs cgroup /sys/fs/cgroup

# Need manual changes
# Add the following string inside of the GRUB_CMDLINE_LINUX_DEFAULT variable:
# cgroup_enable=memory swapaccount=1

${SUDO} apt-get install -y cgroup-tools cgroup-tools cgroupfs-mount libcgroup1 numactl

if [ ! -d "/cgroup/cpu-n-ram" ]; then
	${SUDO} mkdir -p /cgroup/cpu-n-ram
fi

if [ -f "/etc/cgconfig.conf" ]; then
	# Backup of existing configuration if any
	${SUDO} mv /etc/cgconfig.conf /etc/cgconfig-${CURRENT_DATE}.conf
	${SUDO} mv /etc/cgrules.conf /etc/cgrules-${CURRENT_DATE}.conf
	${SUDO} mv /etc/cgred.conf /etc/cgred-${CURRENT_DATE}.conf
fi

# Copy default configuration file
${SUDO} cp /usr/share/doc/cgroup-tools/examples/cgred.conf /etc

# Copying configuration to /etc
${SUDO} cp $HOME/.vim/bin/conf.d/cgconfig.conf /etc
${SUDO} cp $HOME/.vim/bin/conf.d/cgrules.conf /etc

${SUDO} /usr/sbin/cgconfigparser -l /etc/cgconfig.conf
${SUDO} /usr/sbin/cgrulesengd -vvv


${SUDO} systemctl daemon-reload
${SUDO} systemctl enable cgconfigparser
${SUDO} systemctl enable cgrulesgend
${SUDO} systemctl start cgconfigparser
${SUDO} systemctl start cgrulesgend



# check if cgroup’s are working properly
# cat /sys/fs/cgroup/cpu/web2/tasks
# cat /sys/fs/cgroup/memory/web2/tasks


## vallabh @ vrkansagara.local ➜  .vim git:(master) mount | grep cgroup
# cgroup2 on /sys/fs/cgroup type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate,memory_recursiveprot)

