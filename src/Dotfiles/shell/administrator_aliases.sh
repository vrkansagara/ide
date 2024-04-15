## Linux Administrator commands

# some more ls aliases
alias ll='ls -lA'
alias la='ls -A'
alias l='ls -CF'

alias myDmesgWatch='watch "sudo dmesg | tail -20"'
alias myDmesgError='sudo dmesg --level=emerg,alert,crit,err | tail -20'
alias myVarLogError="sudo grep -i -r 'error' -v '1password_1password.desktop\|snap.1password.1password' /var/log/syslog"
alias myListen="sudo lsof -iTCP -sTCP:LISTEN -Pn"
alias myListeN="sudo netstat -natp"
alias myWatch="sudo watch ss -tp"
alias myWatchN="sudo netstat -A inet -p"
alias myWatchWho="sudo netstat -A inet -p | grep '^tcp' | grep '/' | sed 's_.*/__' | sort | uniq"
# alias myWatchWhO="sudo ss -tp | grep -v Recv-Q | sed -e 's/.*users:((\"//' -e 's/\".*$//' | sort | uniq"
alias myTop10Processes='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head'
alias myTop10ProcessesVirtualMemeory='ps -eo vsz,pid,ppid,cmd,%mem,%cpu --sort=-vsz | head'
# Let’s view the threads of a process interactively by embedding our ps command in the –preview flag:
alias myPs="ps axo pid,rss,comm --no-headers | fzf --preview 'ps o args {1}; ps mu {1}'"
alias myPsMemory='ps -o pid,user,%mem,command ax | sort -b -k3 -r | fzf'
alias myPsilent='ps -ef | grep "teams\|skype\|slack\|discord" | grep -v grep | awk "{print \$2}" | xargs -I {} sudo kill -9 {} '

# package dependencies
alias myDebDependencies="apt-cache search . | fzf --preview 'apt-cache depends {1}' "
alias myPublicIp='dig +short myip.opendns.com @resolver1.opendns.comss
'
alias myPublicIP="dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '\"'"
alias myPublicIPCloud=`curl -fSs https://1.1.1.1/cdn-cgi/trace | awk -F= '/ip/ { print $2 }'`
alias myPublicIpv6='dig -6 TXT +short o-o.myaddr.l.google.com @ns1.google.com'
alias myAllIp="ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}'"

# alias myIp="echo $(hostname -I | awk '{print $1}')"
alias myCpuInfo="lscpu | egrep 'Model name|Socket|Thread|NUMA|CPU\(s\)'"

# sensors| grep -i rpm | awk '{ print "Fan "$3"/"$11" RPM"}'

alias ownIt='sudo chown -Rf $USER:$USER '
alias ownItWithPermission='sudo chmod 0744 -Rf'
alias currentMonitor='xrandr | grep " connected" | cut -f1 -d " "'
alias setBrightness='echo "xrandr --output eDP-1 --brightness 0.75"'
alias setMyBrightness="echo 15000 | sudo tee  /sys/class/backlight/intel_backlight/brightness"
alias setMyBrightnessAnother="echo 7 | sudo tee /sys/class/backlight/acpi_video0/brightness"
alias myLimit="/usr/bin/cpulimit -c 30  "
alias myHtop="/usr/bin/htop -u $USER "
alias mtHtopDelay="/usr/bin/htop -u $USER -d 60"
# alias myHtopFirefox="$(which htop) -p $(pidof firefox | sed 's/ /,/g')"

# File finder
alias myFindFile="sudo find / -type f  -name "
alias myFindDirectory="find / -type d  -name "
alias myFindLastModified="find $(pwd) \( ! -regex '.*/\..*' \) -type f -print0 | xargs -0 stat --format '%Y :%y %n' | sort -nr | cut -d: -f2- | head"
# -r = recursive -n= line numer -w match whole world -e=pattern used for search --include=\*.{xml,php} --exclude=\*.o
alias myFindTextIntoDirectory="grep -rnw -e "
