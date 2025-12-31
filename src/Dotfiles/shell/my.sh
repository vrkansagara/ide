# @usage
# (1) copy original zshrc and inject top and bottom code
# (2) Top code
# (3) Bottom code

# -------------------------------------------------
# Interactive-safe output
# -------------------------------------------------
[[ -o interactive ]] && echo "Loading ..... $0"

# -------------------------------------------------
# Identity (DO NOT override $USER)
# -------------------------------------------------
export USER_ID="$(id -u)"
export GROUP_ID="$(id -g)"
export GROUP="$(id -gn)"

# -------------------------------------------------
# PATH handling (ZSH-CORRECT)
# -------------------------------------------------
typeset -aU path   # lowercase path is the array; PATH stays scalar

#### @vrkansagara @START
command_exists() {
  command -v "$@" >/dev/null 2>&1
}

alias g='git'
alias ss='source ~/.zshrc'
alias h="history 0"
alias o="open ."

# -------------------------------------------------
# Vim / File Manager
# -------------------------------------------------
alias v='vim -u NONE -N -U NONE'
alias vi='cd ~/.vim && vim'
alias viml='vim --startuptime /tmp/vim-startup.log'
alias vimDebug="vim --cmd 'profile start /tmp/vim-profiling.log' --cmd 'profile func *' --cmd 'profile file *' -c 'profdel func *' -c 'profdel file *' -c 'qa!'"

alias www='cd $HOME/www'
alias htdocs='cd $HOME/htdocs'
alias gh='cd $HOME/git'

# -------------------------------------------------
# Alerts
# -------------------------------------------------
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# -------------------------------------------------
# Build / Debug
# -------------------------------------------------
alias makev="make --warn-undefined-variables "
alias gcc="gcc -g "
alias gdb="sudo gdb "
alias lkmLog="sudo tail -f /var/log/syslog"
alias lkmCrash="echo 'sudo /usr/bin/crash /var/crash/202110071450/dump.202110071450 /usr/lib/debug/boot/vmlinux-5.4.0-88-generic'"
alias zshCorruptHistoryRepair="mv ~/.zsh_history ~/.zsh_history_bad && strings -eS ~/.zsh_history_bad > ~/.zsh_history && fc -R ~/.zsh_history"

# -------------------------------------------------
# Prompt helper
# -------------------------------------------------
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment white default "%(!.%{%F{yellow}%}.)$USER"
  fi
}

# -------------------------------------------------
# Custom shell extensions
# -------------------------------------------------
source "$HOME/.vim/src/Dotfiles/shell/bash_color.sh"
source "$HOME/.vim/src/Dotfiles/shell/bash_functions.sh"
source "$HOME/.vim/src/Dotfiles/shell/administrator_aliases.sh"
source "$HOME/.vim/src/Dotfiles/shell/docker_aliases.sh"
source "$HOME/.vim/src/Dotfiles/shell/aws_aliases.sh"
source "$HOME/.vim/src/Dotfiles/shell/php_aliases.sh"

# -------------------------------------------------
# Autosuggestions
# -------------------------------------------------
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# -------------------------------------------------
# command-not-found
# -------------------------------------------------
if [ -f /etc/zsh_command_not_found ]; then
  source /etc/zsh_command_not_found
fi

# -------------------------------------------------
# Zsh behavior
# -------------------------------------------------
setopt autocd

# -------------------------------------------------
# Composer
# -------------------------------------------------
export COMPOSER_PROCESS_TIMEOUT=5000

# -------------------------------------------------
# History
# -------------------------------------------------
export HISTSIZE=10000000
export SAVEHIST=10000000
mkdir -p "$HOME/.vim/data/cache"
export HISTFILE="$HOME/.vim/data/cache/zsh"

# -------------------------------------------------
# Neovim debug
# -------------------------------------------------
export NVIM_COC_LOG_LEVEL=debug
export NVIM_COC_LOG_FILE="/tmp/coc-nvim.log"

# -------------------------------------------------
# Java / UI
# -------------------------------------------------
export _JAVA_AWT_WM_NONREPARENTING=1
export AWT_TOOLKIT=MToolkit

# -------------------------------------------------
# Terminal / SSH
# -------------------------------------------------
export TERM=xterm
alias sshx='env TERM=xterm ssh'
alias sshOld='env TERM=xterm ssh -oHostKeyAlgorithms=+ssh-dss '
export GPG_TTY="$(tty)"

# -------------------------------------------------
# PATH entries (ZSH ARRAY STYLE)
# -------------------------------------------------
path=(
  $HOME/.vim/bin
  $HOME/.vim/vendor/bin
  $HOME/.yarn/bin
  $HOME/.config/yarn/global/node_modules/.bin
  $HOME/.cargo/bin
  $HOME/.vim/node_modules/.bin
  /usr/local/bin
  $path
)

# -------------------------------------------------
# Magento Cloud CLI
# -------------------------------------------------
path=(
  $HOME/.magento-cloud/bin
  $path
)

if [ -f "$HOME/.magento-cloud/shell-config.rc" ]; then
  source "$HOME/.magento-cloud/shell-config.rc"
fi

# -------------------------------------------------
# Ruby Gems
# -------------------------------------------------
export GEM_HOME="$HOME/.gem"

# -------------------------------------------------
# Prompt
# -------------------------------------------------
PROMPT="╭─${user_host}${current_dir}${rvm_ruby}${vcs_branch}${venv_prompt} %{$fg[yellow]%}[%D{%f/%m/%Y} %D{%T}] [ Do one thing at a time and do it well ]
╰─%B[卐]%b "
RPROMPT="%B${return_code}%b"

# -------------------------------------------------
# Load .profile last
# -------------------------------------------------
if [ -f "$HOME/.profile" ]; then
  [[ -o interactive ]] && echo "Loading ..... $HOME/.profile"
  source "$HOME/.profile"
fi

# -------------------------------------------------
# Profiling (must be last)
# -------------------------------------------------
if [[ "$ZPROF" = true ]]; then
  zprof
fi
