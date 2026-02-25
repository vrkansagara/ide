# ==============================================================================
# administrator_aliases.sh — Linux administrator aliases and system helpers
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# Usage      : source this file from ~/.bashrc or ~/.zshrc

# Guard against double-sourcing
[ -n "${_LOADED_ADMINISTRATOR_ALIASES_SH:-}" ] && return 0
_LOADED_ADMINISTRATOR_ALIASES_SH=1

# ------------------------------------------------------------------------------
# FZF defaults
# fzf can do things like: vim $(fzf) or cp $(fzf) ~/.config/pipewire
# NOTE: FZF_DEFAULT_COMMAND uses pwd at source time; expand lazily if preferred.
# ------------------------------------------------------------------------------
export FZF_DEFAULT_OPTS="--preview 'cat {}'"
export FZF_DEFAULT_COMMAND="find $(pwd) -type f"

# ------------------------------------------------------------------------------
# Directory listing
# ------------------------------------------------------------------------------
# alias ls='/bin/ls --human-readable --size -1 -S --classify -lAlhtra'
alias ll='/bin/ls -lhtraF'
alias la='ls -A'
alias l='ls -CF'
alias c='clear'  # clear interface

# ------------------------------------------------------------------------------
# Disk usage
# ------------------------------------------------------------------------------
alias du='/usr/bin/du -sh '

# ------------------------------------------------------------------------------
# Kernel / system log
# ------------------------------------------------------------------------------
alias myDmesgWatch='watch "sudo dmesg -T | tail -20"'
alias myDmesgError='sudo dmesg -T --level=emerg,alert,crit,err | tail -20'

alias myVarLogError="sudo grep -i -r 'error' -v '1password_1password.desktop\|snap.1password.1password' /var/log/syslog"

# ------------------------------------------------------------------------------
# Network monitoring
# ------------------------------------------------------------------------------
alias myListen='sudo lsof -iTCP -sTCP:LISTEN -Pn'
alias myListeN='sudo netstat -natp'

alias myWatch='sudo watch ss -tp'
alias myWatchN='sudo netstat -A inet -p'
alias myWatchWho="sudo netstat -A inet -p | grep '^tcp' | grep '/' | sed 's_.*/__' | sort | uniq"

# alias myWatchWhO="sudo ss -tp | grep -v Recv-Q | sed -e 's/.*users:((\"//' -e 's/\".*$//' | sort | uniq"

# ------------------------------------------------------------------------------
# Process inspection
# ------------------------------------------------------------------------------
alias myTop10Processes='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head'
alias myTop10ProcessesVirtualMemeory='ps -eo vsz,pid,ppid,cmd,%mem,%cpu --sort=-vsz | head'

# View threads of a process interactively via fzf --preview
alias myPs="ps axo pid,rss,comm --no-headers | fzf --preview 'ps o args {1}; ps mu {1}'"
alias myPsMemory='ps -o pid,user,%mem,command ax | sort -b -k3 -r | fzf'
alias myPsilent='ps -ef | grep "teams\|skype\|slack\|discord" | grep -v grep | awk "{print \$2}" | xargs -I {} sudo kill -9 {} '

# ------------------------------------------------------------------------------
# Package management
# ------------------------------------------------------------------------------
alias myDebDependencies="apt-cache search . | fzf --preview 'apt-cache depends {1}'"

# ------------------------------------------------------------------------------
# Public IP helpers
# NOTE: myPublicIp had a stray 'ss' and stray newline in the original — fixed.
# ------------------------------------------------------------------------------
alias myPublicIp='dig +short myip.opendns.com @resolver1.opendns.com'
alias myPublicIP="dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '\"'"
alias myPublicIPCloud="curl -fSs https://1.1.1.1/cdn-cgi/trace | awk -F= '/ip/ { print \$2 }'"
alias myPublicIpv6='dig -6 TXT +short o-o.myaddr.l.google.com @ns1.google.com'
alias myAllIp="ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}'"

# alias myIp="echo $(hostname -I | awk '{print $1}')"
alias myCpuInfo="lscpu | grep -E 'Model name|Socket|Thread|NUMA|CPU\(s\)'"

# sensors| grep -i rpm | awk '{ print "Fan "$3"/"$11" RPM"}'

# ------------------------------------------------------------------------------
# Ownership / permissions
# ------------------------------------------------------------------------------
alias ownIt='sudo chown -Rf "$USER":"$USER" '
alias ownItWithPermission='sudo chmod 0744 -Rf'

# ------------------------------------------------------------------------------
# Display / brightness
# ------------------------------------------------------------------------------
alias currentMonitor='xrandr | grep " connected" | cut -f1 -d " "'

alias setBrightness='echo "xrandr --output eDP-1 --brightness 0.75"'
alias setMyBrightness='echo 15000 | sudo tee /sys/class/backlight/intel_backlight/brightness'
alias setMyBrightnessAnother='echo 7 | sudo tee /sys/class/backlight/acpi_video0/brightness'

# ------------------------------------------------------------------------------
# CPU / resource limiting
# ------------------------------------------------------------------------------
alias myLimit='/usr/bin/cpulimit -c 30 '

alias myHtop="/usr/bin/htop -u $USER "
alias mtHtopDelay="/usr/bin/htop -u $USER -d 60"
# alias myHtopFirefox="$(which htop) -p $(pidof firefox | sed 's/ /,/g')"

# ------------------------------------------------------------------------------
# File finder helpers
# -r=recursive -n=line number -w=match whole word -e=pattern --include=\*.{xml,php} --exclude=\*.o
# ------------------------------------------------------------------------------
alias myFindFile='sudo find / -type f -name '
alias myFindDirectory='find / -type d -name '
alias myFindLastModified="find $(pwd) \( ! -regex '.*/\..*' \) -type f -print0 | xargs -0 stat --format '%Y :%y %n' | sort -nr | cut -d: -f2- | head"

# ------------------------------------------------------------------------------
# Hardware information
# ------------------------------------------------------------------------------
alias myHardwareInformation='inxi -Fxz'
