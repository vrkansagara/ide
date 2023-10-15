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
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Setting up cgroup for process controll
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# /etc/fstab
# cgroup /sys/fs/cgroup cgroup defaults,blkio,net_cls,freezer,devices,cpuacct,cpu,cpuset,memory,clone_children 0 0

# This will select only the mounts that are part of cgroup version 1, taking just
# their mount points and then unmounting them.
sudo mount -t cgroup | cut -f 3 -d ' ' | xargs sudo umount

sudo mount -o remount,rw /sys/fs/cgroup
# Delete the symlinks
sudo find /sys/fs/cgroup -maxdepth 1 -type l -exec rm {} \;
# Delete the empty directories
# sudo find /sys/fs/cgroup/ -links 2 -type d -not -path '/sys/fs/cgroup/unified/*' -exec rmdir -v {} \;
sudo mount -o remount,ro /sys/fs/cgroup

# if cgroup is supported by your kernel
# grep "cgroup" /proc/filesystems

# Add the following line to /etc/fstab:
# cgroup /sys/fs/cgroup cgroup defaults
# For a one-time thing, mount it manually:
# sudo  mount -t cgroup cgroup /sys/fs/cgroup

#Edit kernel options in /etc/default/grub:
# GRUB_CMDLINE_LINUX_DEFAULT="quiet cgroup_enable=memory,namespace"
#update-grub

# sudo mount -t cgroup -o memory cgroup_memory /sys/fs/cgroup/memory
# And that's assuming that /sys/fs/cgroup is mounted at all.
# sudo mount -t tmpfs cgroup /sys/fs/cgroup

# Need manual changes
# Add the following string inside of the GRUB_CMDLINE_LINUX_DEFAULT variable:
# cgroup_enable=memory swapaccount=1

YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt)
OTHER_CMD=$(which def)

if [[ ! -z $YUM_CMD ]]; then
	${SUDO} yum -y libcgroup libcgroup-tools
elif [[ ! -z $APT_GET_CMD ]]; then
	${SUDO} apt install -y libcgroup1 cgroup-tools cgroupfs-mount
elif [[ ! -z $OTHER_CMD ]]; then
	${SUDO} $OTHER_CMD other-project-install
else
	echo "error can't install package $PACKAGE"
	exit 1
fi

# From there, you can add tasks into your cgroup using the echo command:
# echo $pid > /sys/fs/cgroup/memory/mycgroup/tasks
# Finally, you can limit the memory usage to 1MB by:
# echo 1M > /sys/fs/cgroup/memory/mycgroup/memory.max_usage_in_bytes

sudo mount -t tmpfs cgroup_root /sys/fs/cgroup
sudo mkdir /sys/fs/cgroup/cpuset
sudo mkdir /sys/fs/cgroup/cpu
sudo mkdir /sys/fs/cgroup/memory

sudo mount -t cgroup cpuset -o cpuset /sys/fs/cgroup/cpuset/
sudo mount -t cgroup memory -o cpu /sys/fs/cgroup/cpu/
sudo mount -t cgroup memory -o memory /sys/fs/cgroup/memory/

# Check weather the cgroup2 is mounted or not
cat /proc/mounts | grep cgroup
ls -lA /sys/fs/cgroup/

# sudo mount -t cgroup -o cpu,memory,name=cgroup2 cgroup /sys/fs/cgroup

if [ -f "/etc/cgconfig.conf" ]; then
	# Backup of existing configuration if any
	${SUDO} mv /etc/cgred.conf /etc/cgred-${CURRENT_DATE}.conf
	${SUDO} mv /etc/cgconfig.conf /etc/cgconfig-${CURRENT_DATE}.conf
	${SUDO} mv /etc/cgrules.conf /etc/cgrules-${CURRENT_DATE}.conf
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

# root@vrkansagara:~# ls /sys/fs/cgroup/
# cgroup.controllers	cgroup.threads	       dev-mqueue.mount  memory.numa_stat		sys-kernel-debug.mount
# cgroup.max.depth	cpu.pressure	       init.scope	 memory.pressure		sys-kernel-tracing.mount
# cgroup.max.descendants	cpuset.cpus.effective  io.cost.model	 memory.stat			system.slice
# cgroup.procs		cpuset.mems.effective  io.cost.qos	 -.mount			user.slice
# cgroup.stat		cpu.stat	       io.pressure	 sys-fs-fuse-connections.mount
# cgroup.subtree_control	dev-hugepages.mount    io.stat		 sys-kernel-config.mount
