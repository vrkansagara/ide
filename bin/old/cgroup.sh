#!/usr/bin/env bash
# ==============================================================================
# cgroup.sh — set up cgroup v1 mounts, install tools, and configure services
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0

set -o errexit
set -o pipefail
set -o nounset

readonly VERSION="2.0.0"
readonly PROGNAME="${0##*/}"
VERBOSE=0
SUDO_CMD=""

_init_colors() {
    if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
        C_RESET="$(tput sgr0   2>/dev/null || printf '')"; C_GREEN="$(tput setaf 2 2>/dev/null || printf '')"
        C_YELLOW="$(tput setaf 3 2>/dev/null || printf '')"; C_RED="$(tput setaf 1 2>/dev/null || printf '')"
        C_CYAN="$(tput setaf 6  2>/dev/null || printf '')"; C_BOLD="$(tput bold   2>/dev/null || printf '')"
    else
        C_RESET=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''; C_BOLD=''
    fi
}
_init_colors

info()    { printf '%b[INFO]  %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
warn()    { printf '%b[WARN]  %s%b\n' "$C_YELLOW" "$*" "$C_RESET"; }
fatal()   { printf '%b[FATAL] %s%b\n' "$C_RED"    "$*" "$C_RESET" >&2; exit 1; }
ok()      { printf '%b[OK]    %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
log()     { [ "$VERBOSE" -ne 0 ] && printf '[DEBUG] %s\n' "$*" || true; }
section() { printf '\n%b=== %s ===%b\n' "${C_BOLD}${C_CYAN}" "$*" "$C_RESET"; }

usage() {
    printf 'Usage: %s [OPTIONS]\n\n' "$PROGNAME"
    printf 'Set up cgroup v1 mounts, install cgroup tools, and configure services.\n\n'
    printf 'Note: Setting up cgroup for process control.\n\n'
    printf 'Options:\n'
    printf '  -v, --verbose    Enable verbose/debug output\n'
    printf '      --version    Print version and exit\n'
    printf '  -h, --help       Show this help message\n'
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose)  VERBOSE=1 ;;
            --version)     printf '%s version %s\n' "$PROGNAME" "$VERSION"; exit 0 ;;
            -h|--help)     usage; exit 0 ;;
            *)             fatal "Unknown option: $1" ;;
        esac
        shift
    done
}

main() {
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
    log "Started at ${CURRENT_DATE}"

    # /etc/fstab
    # cgroup /sys/fs/cgroup cgroup defaults,blkio,net_cls,freezer,devices,cpuacct,cpu,cpuset,memory,clone_children 0 0

    # This will select only the mounts that are part of cgroup version 1, taking just
    # their mount points and then unmounting them.
    section "Unmounting existing cgroup v1 mounts"
    _run mount -t cgroup | cut -f 3 -d ' ' | xargs _run umount || true

    _run mount -o remount,rw /sys/fs/cgroup
    # Delete the symlinks
    _run find /sys/fs/cgroup -maxdepth 1 -type l -exec rm {} \;
    # Delete the empty directories
    # _run find /sys/fs/cgroup/ -links 2 -type d -not -path '/sys/fs/cgroup/unified/*' -exec rmdir -v {} \;
    _run mount -o remount,ro /sys/fs/cgroup

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

    section "Installing cgroup packages"
    YUM_CMD=$(which yum 2>/dev/null || true)
    APT_GET_CMD=$(which apt 2>/dev/null || true)
    OTHER_CMD=$(which def 2>/dev/null || true)

    if [[ -n "$YUM_CMD" ]]; then
        _run yum -y libcgroup libcgroup-tools
    elif [[ -n "$APT_GET_CMD" ]]; then
        _run apt install -y libcgroup1 cgroup-tools cgroupfs-mount
    elif [[ -n "$OTHER_CMD" ]]; then
        _run "$OTHER_CMD" other-project-install
    else
        fatal "error can't install package: no supported package manager found"
    fi

    # From there, you can add tasks into your cgroup using the echo command:
    # echo $pid > /sys/fs/cgroup/memory/mycgroup/tasks
    # Finally, you can limit the memory usage to 1MB by:
    # echo 1M > /sys/fs/cgroup/memory/mycgroup/memory.max_usage_in_bytes

    section "Mounting cgroup subsystems"
    _run mount -t tmpfs cgroup_root /sys/fs/cgroup
    _run mkdir /sys/fs/cgroup/cpuset
    _run mkdir /sys/fs/cgroup/cpu
    _run mkdir /sys/fs/cgroup/memory

    _run mount -t cgroup cpuset -o cpuset /sys/fs/cgroup/cpuset/
    _run mount -t cgroup memory -o cpu /sys/fs/cgroup/cpu/
    _run mount -t cgroup memory -o memory /sys/fs/cgroup/memory/

    # Check weather the cgroup2 is mounted or not
    cat /proc/mounts | grep cgroup || true
    ls -lA /sys/fs/cgroup/

    # sudo mount -t cgroup -o cpu,memory,name=cgroup2 cgroup /sys/fs/cgroup

    section "Configuring cgroup config files"
    if [ -f "/etc/cgconfig.conf" ]; then
        # Backup of existing configuration if any
        _run mv /etc/cgred.conf "/etc/cgred-${CURRENT_DATE}.conf"
        _run mv /etc/cgconfig.conf "/etc/cgconfig-${CURRENT_DATE}.conf"
        _run mv /etc/cgrules.conf "/etc/cgrules-${CURRENT_DATE}.conf"
    fi

    # Copy default configuration file
    _run cp /usr/share/doc/cgroup-tools/examples/cgred.conf /etc

    # Copying configuration to /etc
    _run cp "$HOME/.vim/bin/conf.d/cgconfig.conf" /etc
    _run cp "$HOME/.vim/bin/conf.d/cgrules.conf" /etc

    _run /usr/sbin/cgconfigparser -l /etc/cgconfig.conf
    _run /usr/sbin/cgrulesengd -vvv

    section "Enabling cgroup systemd services"
    _run systemctl daemon-reload
    _run systemctl enable cgconfigparser
    _run systemctl enable cgrulesgend
    _run systemctl start cgconfigparser
    _run systemctl start cgrulesgend

    # check if cgroup's are working properly
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

    ok "cgroup setup complete."
}
main "$@"
