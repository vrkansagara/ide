# This will be the first line of the .zshrc
# if [[ "$ZPROF" = true ]]; then
#   zmodload zsh/zprof
# fi

#### @VRKANSAGARA @START
# https://rabexc.org/posts/pitfalls-of-ssh-agents ( Be careful !!! )
# ssh-add -l &>/dev/null
# if [ "$?" == 2 ]; then
#   test -r ~/.ssh-agent && \
#     eval "$(<~/.ssh-agent)" >/dev/null

#   ssh-add -l &>/dev/null
#   if [ "$?" == 2 ]; then
#     (umask 066; ssh-agent > ~/.ssh-agent)
#     eval "$(<~/.ssh-agent)" >/dev/null
#     ssh-add
#   fi
# fi

alias ss='source ~/.zshrc'
# alias ls='/bin/ls --human-readable --size -1 -S --classify -lAlhtra'
alias ll='/bin/ls -lhtraF'
alias la='ls -A'
alias l='ls -CF'

# Docker Related stuff #
# sudo curl -L
# "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname
# -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose
# dc up -dV --build --remove-orphan --force-recreate
alias d='docker '
alias de='docker exec -it '
alias dc='docker-compose '
alias dce='docker-compose exec -u $(whoami) '
alias dcE='docker-compose exec -u root '
alias ds='docker-compose ps --services'
alias dcb='docker-compose up -dV --build --remove-orphan --force-recreate '
alias dcu='docker-compose up -dV --remove-orphan --force-recreate '
alias dcl='docker-compose logs --follow --timestamps --tail 50 '
alias dIps="docker ps -q | xargs -n 1 docker inspect --format '{{ .NetworkSettings.IPAddress }} {{ .Name }} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' | sed 's/ \// /'"

#File Manager related stuff #

# Vim debug mode vim -u NONE --startuptime vim-NONE.log
alias v='vim -u NONE -N -U NONE'
alias vi='cd ~/.vim && vim'
alias viml='vim --startuptime /tmp/vim-startup.log'
alias vimDebug="vim --cmd 'profile start /tmp/vim-profiling.log' --cmd 'profile func *' --cmd 'profile file *' -c 'profdel func *' -c 'profdel file *' -c 'qa!'"

alias www='cd ~/www'
alias htdocs='cd ~/htdocs'
alias gh='cd ~/git'

alias du='/usr/bin/du -sh  '

# Git alias ( Apart from git config )
alias gc='git commit -S '

## Linux Administator commands
alias myDmesgWatch='watch "dmesg | tail -20"'
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
alias myPublicIp='dig +short myip.opendns.com @resolver1.opendns.com'
alias myPublicIP='dig +short txt ch whoami.cloudflare @1.0.0.1'
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

# For Git
alias myGitLs='for i in */; do (cd $i && echo -n "$(pwd) <=> " && git rev-parse --abbrev-ref HEAD);  done'
alias myGitLog="git log --oneline | fzf --preview 'git show --name-only {1}'"
# PHP Aliases
alias myPhpRun='php -S 0.0.0.0:12345 -d ./'
alias myPhpRunInPublic='php -S 0.0.0.0:12345 -d public/index.php -t public'

# File finder
alias myFindFile="sudo find / -type f  -name "
alias myFindDirectory="find / -type d  -name "
alias myFindLastModified="find $(pwd) \( ! -regex '.*/\..*' \) -type f -print0 | xargs -0 stat --format '%Y :%y %n' | sort -nr | cut -d: -f2- | head"
# -r = recursive -n= line numer -w match whole world -e=pattern used for search
alias myFindTextIntoDirectory="grep -rnw -e "

# AWS Aliases
alias myaAsMyInfo='curl http://169.254.169.254/latest/meta-data/'

# PHP Laminas server
alias myPhpComposerRun='composer run-script serve --timeout 0'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

## Build related stuff"
# Build file should not have any unwanted variables.
alias makev="make --warn-undefined-variables "
alias gcc="gcc -g "
alias gdb="sudo gdb "

alias lkmLog="sudo tail -f /var/log/syslog"
alias lkmCrash="echo 'sudo /usr/bin/crash /var/crash/202110071450/dump.202110071450 /usr/lib/debug/boot/vmlinux-5.4.0-88-generic'"
alias zshCorruptHistoryRepair="mv ~/.zsh_history ~/.zsh_history_bad && strings -eS ~/.zsh_history_bad > ~/.zsh_history && fc -R ~/.zsh_history"

# echo -ne '\e[5 q' # Use beam shape cursor on startup.
# preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.
# bindkey -s '^f' 'cd "$(dirname "$(fzf)")"\n'
# # bindkey -s '^r' 'history | fzf\n'
# bindkey -s '^p' 'ps -aux | fzf\n'
# bindkey -s '^h' 'htop -u $USER \n'

# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load Angular CLI autocompletion.
# source <(ng completion script)

# Let's rust do it's own
# [ -f $HOME/.cargo/env ] && source "$HOME/.cargo/env"

# SVN Alias
alias svnInfo='svn info'
alias svnRevision='svn info |grep Revision: |cut -c11-'


prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment white default "%(!.%{%F{yellow}%}.)$USER"
  fi
}




# Mac specific
export nproc=$(sysctl -n hw.logicalcpu)
alias juliA="/usr/local/bin/julia --compiled-modules=yes --startup-file=no --banner=no "

# CUSTOM FROM HERE....
# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples
source "$HOME/.vim/src/Dotfiles/shell/bash_functions.sh"
source $HOME/.vim/src/Dotfiles/shell/git_aliases.sh

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# enable auto-suggestions based on the history
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

## Original VRKANSAGARA start from bellow
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

# Enable colors and change prompt:
# autoload -U colors && colors	# Load colors
setopt autocd		# Automatically cd into typed directory.
# stty stop undef		# Disable ctrl-s to freeze terminal.
# setopt interactive_comments

COMPOSER_PROCESS_TIMEOUT=5000

# History in cache directory:
# HISTSIZE=10000000
# SAVEHIST=10000000
# HISTFILE=~/.vim/data/cache/zsh

## VIM plugines debug
export NVIM_COC_LOG_LEVEL=debug
export NVIM_COC_LOG_FILE="/tmp/coc-nvim.log"

# Used for the phpStorm program and java application to work with DWM
export _JAVA_AWT_WM_NONREPARENTING=1 # If you come from bash you might have to change your $PATH.
export AWT_TOOLKIT=MToolkit
# wmname LG3D

# export DISPLAY=:0
# Yes,I use st( Terminal base would be xterm (to avoide VIM and Remote SSH X )
# export TERM=xterm
# Remote sessin would be xterm base (Avoide st-256 issue at remote)
alias ssh='env TERM=xterm ssh'
alias sshOld='env TERM=xterm ssh -oHostKeyAlgorithms=+ssh-dss '
export GPG_TTY=$(tty)
# If you come from bash you might have to change your $PATH.
export PATH="$(getconf PATH)" # reset system default
export PATH="$HOME/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.vim/bin:$HOME/.vim/vendor/bin:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.vim/node_modules/.bin:$PATH"
export PATH="/snap/bin:$PATH"

# BEGIN SNIPPET: Magento Cloud CLI configuration
HOME=${HOME:-"/home/$USER"}
export PATH="$HOME/"'.magento-cloud/bin':"$PATH"
if [ -f "$HOME/"'.magento-cloud/shell-config.rc' ]; then . "$HOME/"'.magento-cloud/shell-config.rc'; fi
# END SNIPPET

# Lets include into $HOME/.zshrc file
# Lets call my custom configuration for the shell
# source $HOME/.vim/src/Dotfiles/shell/my.sh

if [ -f "$HOME/.profile" ]; then
    . $HOME/.profile
fi

# zsh-completions
 if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    autoload -Uz compinit
    compinit
chmod go-w '/opt/homebrew/share'
chmod -R go-w '/opt/homebrew/share/zsh'
  fi


# This must be the last line of $HOME/.zshrc becuse From bash_functions.sh@profzsh will call for the profilling
if [[ "$ZPROF" = true ]]; then
  zprof
fi
