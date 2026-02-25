#!/usr/bin/env bash
# ==============================================================================
# tuneup.sh — Standard Linux system tune-up: kernel params, cache, services
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# Note       : This is standard linux tune up script

set -o errexit
set -o pipefail
set -o nounset

# ------------------------------------------------------------------------------
# Constants + state
# ------------------------------------------------------------------------------
readonly VERSION="2.0.0"
readonly PROGNAME="${0##*/}"
VERBOSE=0
SUDO_CMD=""

# ------------------------------------------------------------------------------
# Color block
# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
# Logging helpers
# ------------------------------------------------------------------------------
info()    { printf '%b[INFO]  %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
warn()    { printf '%b[WARN]  %s%b\n' "$C_YELLOW" "$*" "$C_RESET"; }
fatal()   { printf '%b[FATAL] %s%b\n' "$C_RED"    "$*" "$C_RESET" >&2; exit 1; }
ok()      { printf '%b[OK]    %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
log()     { [ "$VERBOSE" -ne 0 ] && printf '[DEBUG] %s\n' "$*" || true; }
section() { printf '\n%b=== %s ===%b\n' "${C_BOLD}${C_CYAN}" "$*" "$C_RESET"; }

# ------------------------------------------------------------------------------
# Usage
# ------------------------------------------------------------------------------
usage() {
    cat <<EOF
Usage: $PROGNAME [OPTIONS]

Performs a standard Linux system tune-up including:
  - Kernel parameter tuning (vm, fs, net, inotify)
  - Cache and swap clearing
  - Stopping unwanted background services
  - Log file cleanup (older than 3 days)
  - APT package management (update, upgrade, autoremove, clean)
  - AppArmor and snapd service restart

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message

References:
  https://klaver.it/linux/sysctl.conf
  https://people.redhat.com/alikins/system_tuning.html#tcp
  https://cromwell-intl.com/open-source/performance-tuning/nfs.html

Example:
  $PROGNAME
  $PROGNAME --verbose
EOF
}

# ------------------------------------------------------------------------------
# Sudo wrapper
# ------------------------------------------------------------------------------
_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

# ------------------------------------------------------------------------------
# Argument parsing
# ------------------------------------------------------------------------------
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose) VERBOSE=1; set -x; shift ;;
            --version)    printf '%s v%s\n' "$PROGNAME" "$VERSION"; exit 0 ;;
            -h|--help)    usage; exit 0 ;;
            --)           shift; break ;;
            -*)           fatal "Unknown option: '$1'. Use -h for help." ;;
            *)            break ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# Kernel tuneup — writes /etc/sysctl.d/local.conf
# ------------------------------------------------------------------------------
kernel_tuneup() {
    printf '%s' '
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
' | _run tee /etc/sysctl.d/local.conf >/dev/null
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    parse_args "$@"
    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    # Resolve the directory containing this script
    local SCRIPT_DIR
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

    local CURRENT_DATE
    CURRENT_DATE="$(date '+%Y%m%d%H%M%S')"

    # First thing first
    section "Backup sysctl settings"
    mkdir -p "$HOME/Documents/backup"
    _run sysctl --all >"$HOME/Documents/backup/sysctl-${CURRENT_DATE}.txt"
    ok "sysctl backup saved to $HOME/Documents/backup/sysctl-${CURRENT_DATE}.txt"

    section "Firewall baseline"
    _run ufw default allow outgoing
    _run ufw default deny incoming
    _run ufw enable
    _run ufw reload

    # Give *.sh execute permission for the working directory
    _run find "${SCRIPT_DIR}" -name '*.sh' -exec ls -lA {} +

    # Cache clearing
    # 1. Clear PageCache only.
    # 2. Clear dentries and inodes.
    # 3. Clear PageCache, dentries and inodes.
    # Note: we are using "echo 3", but it is not recommended in production;
    # use "echo 1" instead. Writing to this will cause the kernel to drop
    # clean caches, as well as reclaimable slab objects like dentries and
    # inodes. Once dropped, their memory becomes free.
    section "Clearing kernel caches"
    _run sysctl vm.drop_caches=3
    ok "Kernel caches cleared."

    # Clear Swap Space in Linux
    info "Clearing swap space..."
    _run swapoff -a && _run swapon -a
    ok "Swap cleared and re-enabled."

    _run sysctl -p

    # Clear program cache/remove
    section "Removing thumbnail cache"
    _run rm -rfv "$HOME/.cache/thumbnails"
    # Uncomment as needed:
    # _run rm -rfv ~/.mozilla
    # _run rm -rfv ~/.cache/mozilla
    # _run rm -rfv ~/.config/google-chrome
    # cp -r -v ~/.config/google-chrome ~/.config/google-chromebackup
    # /etc/sysctl.conf

    section "Kernel VM tuning"
    # swappiness
    # This control is used to define how aggressive the kernel will swap
    # memory pages. Higher values will increase aggressiveness, lower values
    # decrease the amount of swap. A value of 0 instructs the kernel not to
    # initiate swap until the amount of free and file-backed pages is less
    # than the high water mark in a zone.
    # The default value is 60.
    # For Redis instances it should be 1.
    _run sysctl -w vm.swappiness=10

    # This percentage value controls the tendency of the kernel to reclaim
    # the memory which is used for caching of directory and inode objects
    # (Default = 100).
    # vfs_cache_pressure — Controls the kernel's tendency to reclaim the
    # memory used for caching of directory and inode objects.
    # (default = 100, recommended value: 50 to 200)
    _run sysctl -n vm.vfs_cache_pressure
    _run sysctl -w vm.vfs_cache_pressure=200

    # OOM (Out of Memory) Default = 0, Redis = 1
    _run sysctl -w vm.overcommit_memory=0

    # Print default values:
    # vm.dirty_background_ratio=10
    # vm.dirty_ratio=20
    _run sysctl -n vm.dirty_background_ratio
    _run sysctl -w vm.dirty_background_ratio=5
    _run sysctl -w vm.dirty_ratio=10

    # Keep at least 128MB of free RAM space available
    _run sysctl -w vm.min_free_kbytes=128000

    section "File system inotify watcher tuning"
    # Native file system watcher for Linux
    cat /proc/sys/fs/inotify/max_user_watches
    _run sysctl -w fs.inotify.max_user_watches=524288
    _run sysctl -w fs.inotify.max_user_watches=1048576

    section "IPv6 configuration"
    _run sysctl -w net.ipv6.conf.all.disable_ipv6=0
    _run sysctl -w net.ipv6.conf.default.disable_ipv6=0
    _run sysctl -w net.ipv6.conf.lo.disable_ipv6=0

    section "Kernel dmesg cleanup"
    # Clean up dmesg
    # dmesg: read kernel buffer failed: Permission denied
    _run sysctl kernel.dmesg_restrict=0
    _run dmesg -C

    # sysctl - configure kernel parameters at runtime
    # _run sysctl -p

    # Disabling Transparent Huge Pages (THP)
    # (Default(madvise): always [madvise] never)
    # Default: madvise, Redis: never
    # madvise = To prevent applications from allocating more memory resources
    #   than necessary, disable huge pages system-wide and only enable them
    #   inside MADV_HUGEPAGE madvise regions.
    # never = To disable transparent huge pages
    # always = To enable transparent huge pages
    section "Transparent Huge Pages status"
    _run cat /sys/kernel/mm/transparent_hugepage/enabled

    # Set ulimit for current user
    # _run ulimit -v 2048000  # 2 GB for current user
    # _run ulimit -v 4096000  # 4 GB for current user
    # _run ulimit -v 8192000  # 8 GB for current user
    _run ulimit -v 12582912  # 12 GB for current user

    section "Installing Java runtime"
    _run apt install --no-install-recommends --yes default-jre default-jdk
    # _run apt install --no-install-recommends --yes --reinstall gnome-control-center
    # _run apt install --no-install-recommends --yes --reinstall zsh zsh-autosuggestions zsh-common zsh-syntax-highlighting

    # https://gist.github.com/juanje/9861623
    # _run apt-get install cgroup-tools cgroup-lite cgroup-tools cgroupfs-mount libcgroup1

    section "Stopping unwanted services"
    _run systemctl stop bluetooth || true
    _run systemctl stop virtualbox || true
    _run systemctl stop mongodb || true
    _run systemctl stop postgresql || true
    _run systemctl stop mosquitto || true
    _run systemctl stop php5.6-fpm || true
    _run systemctl stop php7.4-fpm || true
    _run systemctl stop php8.0-fpm || true
    _run systemctl stop remotely-agent.service || true
    # _run systemctl stop ufw
    # _run systemctl disable ufw bluetooth virtualbox mongodb mosquitto postgresql.service
    # _run systemctl stop qhclagnt qhdevdmn qhscheduler qhscndmn qhwebsec quickupdate whoopsie
    _run service --status-all | grep + || true

    section "System log review"
    # Finally check system log for any OOM events
    _run grep --color -i -r 'out of memory' /var/log/ || true
    _run grep -i -r 'error' /var/log/syslog | grep -v 'containerd' || true
    _run lshw -c memory || true
    _run apt-get install procps preload --yes --no-install-recommends

    # Inspect current date logs:
    # _run grep -ir $(date "+%b %d") /var/log/syslog

    section "APT cleanup"
    _run apt autoremove || true
    _run apt-get --yes clean
    _run apt-get --yes autoclean
    _run apt-get --yes --purge autoremove
    _run apt-get update --yes --no-install-recommends
    _run apt-get upgrade --yes -v
    # _run apt upgrade --yes --no-install-recommends -v
    # printf 'Acquire::Languages "none";\n' | _run tee -a /etc/apt/apt.conf.d/00aptitude

    # Clean up journalctl (Free up some space), glibc-source, glibc-tools
    # apt install openafs-client
    # https://access.redhat.com/solutions/1450043
    # https://packages.ubuntu.com/focal/amd64/kernel/linux-image-unsigned-5.14.0-1054-oem
    # _run journalctl --vacuum-size=500M
    # Clean up old journal entries older than 3 days
    section "Journal cleanup"
    _run journalctl --vacuum-time=3d
    # List all boots: journalctl --list-boots
    # Check last boot logs: journalctl -b -1 -e

    section "Log file cleanup (older than 3 days)"
    # Delete log files with ".log" extension modified more than 3 days ago
    _run find /var/log/nginx -type f -mtime +3 -delete || true
    _run find /var/log -name "*.log" -type f -mtime +3 -delete || true
    _run find /var/log -name "*.log.*" -type f -mtime +3 -delete || true
    _run find /var/log -type f -regex '.*\.gz$' -delete || true
    _run find /var/log -type f -regex '.*\.[0-9]$' -delete || true

    # Clean apt history logs
    if [ -f "/var/log/apt/history.log" ]; then
        _run head -n 1 /var/log/apt/history.log | _run tee /var/log/apt/history.log
    fi
    if [ -f "/var/log/apt-history.log" ]; then
        _run head -n 1 /var/log/apt-history.log | _run tee /var/log/apt-history.log
    fi

    section "earlyoom installation"
    if ! command -v earlyoom >/dev/null 2>&1; then
        _run apt install earlyoom
        # EARLYOOM_ARGS="-m 5 -r 60 --avoid '(^|/)(init|Xorg|ssh)$' --prefer '(^|/)(java|chromium|google-chrome|skype|teams)$'"
    fi

    # Remove old PhpStorm directories (uncomment as needed):
    # rm -rf ~/.config/JetBrains ~/.local/share/JetBrains ~/.cache/JetBrains
    # rm -rf ~/.local/share/JetBrains/consentOptions
    # rm -rf ~/.java/.userPrefs

    section "GPG agent and AppArmor restart"
    # Restart or bug fix of apt system
    gpgconf --kill gpg-agent || true

    _run service snapd.apparmor restart || true
    _run systemctl enable --now apparmor.service || true
    _run systemctl enable --now snapd.apparmor.service || true

    section "Thread information"
    info "Max threads:"
    _run cat /proc/sys/kernel/threads-max
    info "Total threads running:"
    ps -eo nlwp | awk '$1 ~ /^[0-9]+$/ { n += $1 } END { print n }'

    # Backup sysctl local.conf if present
    if [ -f "/etc/sysctl.d/local.conf" ]; then
        # Back up the resolver config
        _run cp /etc/sysctl.d/local.conf "/etc/sysctl.d/local-${CURRENT_DATE}.conf"
        info "Backed up /etc/sysctl.d/local.conf to local-${CURRENT_DATE}.conf"
    fi

    ok "Tune up of system is complete."

    exit 0
}

main "$@"
