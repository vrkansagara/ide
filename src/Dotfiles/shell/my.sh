# ==============================================================================
# my.sh — Primary shell configuration: aliases, PATH, exports, and sourcing
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# Usage      : source this file from ~/.bashrc or ~/.zshrc
#
# @usage
# (1) Copy original zshrc and inject top and bottom code
# (2) Top code
# (3) Bottom code

# Guard against double-sourcing
[ -n "${_LOADED_MY_SH:-}" ] && return 0
_LOADED_MY_SH=1

# -------------------------------------------------
# Interactive-safe output
# -------------------------------------------------
[[ -o interactive ]] && printf "Loading ..... %s\n" "$0"

# -------------------------------------------------
# Identity (DO NOT override $USER)
# -------------------------------------------------
export USER_ID="${UID}"
export GROUP_ID="${GID}"
export GROUP="$(id -gn)"

# -------------------------------------------------
# PATH handling (ZSH-correct)
# lowercase 'path' is the array; PATH stays the scalar export
# -------------------------------------------------
typeset -aU path   # deduplicate PATH entries

# -------------------------------------------------
# Helper: check if a command exists
# -------------------------------------------------
command_exists() {
  command -v "$@" >/dev/null 2>&1
}

# -------------------------------------------------
# General aliases
# -------------------------------------------------
alias g='git'
alias ss='unset _LOADED_MY_SH && source ~/.zshrc'
alias h='history 0'
alias o='open .'

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
# Alerts — notify when a long-running command finishes
# -------------------------------------------------
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# -------------------------------------------------
# Build / Debug
# -------------------------------------------------
alias makev='make --warn-undefined-variables '
alias gcc='gcc -g '
alias gdb='sudo gdb '
alias lkmLog='sudo tail -f /var/log/syslog'
alias lkmCrash="echo 'sudo /usr/bin/crash /var/crash/202110071450/dump.202110071450 /usr/lib/debug/boot/vmlinux-5.4.0-88-generic'"
alias zshCorruptHistoryRepair="mv ~/.zsh_history ~/.zsh_history_bad && strings -eS ~/.zsh_history_bad > ~/.zsh_history && fc -R ~/.zsh_history"

# -------------------------------------------------
# Prompt helper (oh-my-zsh / powerlevel context)
# -------------------------------------------------
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment white default "%(!.%{%F{yellow}%}.)$USER"
  fi
}

# -------------------------------------------------
# Custom shell extensions
# -------------------------------------------------
for _f in \
    "$HOME/.vim/src/Dotfiles/shell/bash_color.sh" \
    "$HOME/.vim/src/Dotfiles/shell/bash_functions.sh" \
    "$HOME/.vim/src/Dotfiles/shell/administrator_aliases.sh" \
    "$HOME/.vim/src/Dotfiles/shell/docker_aliases.sh" \
    "$HOME/.vim/src/Dotfiles/shell/aws_aliases.sh" \
    "$HOME/.vim/src/Dotfiles/shell/php_aliases.sh"; do
    [ -f "$_f" ] && source "$_f"
done
unset _f

# -------------------------------------------------
# Autosuggestions
# -------------------------------------------------
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# -------------------------------------------------
# command-not-found handler
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
# Neovim / CoC debug
# -------------------------------------------------
export NVIM_COC_LOG_LEVEL=debug
export NVIM_COC_LOG_FILE="/tmp/coc-nvim.log"

# -------------------------------------------------
# Java / UI toolkit
# -------------------------------------------------
export _JAVA_AWT_WM_NONREPARENTING=1
export AWT_TOOLKIT=MToolkit

# -------------------------------------------------
# Terminal / SSH
# -------------------------------------------------
export TERM="${TERM:-xterm-256color}"
alias sshx='env TERM=xterm ssh'
alias sshOld='env TERM=xterm ssh -oHostKeyAlgorithms=+ssh-dss '
export GPG_TTY="${TTY:-$(tty)}"

# -------------------------------------------------
# PATH entries (zsh array style — deduplication via typeset -aU above)
# -------------------------------------------------
path=(
  "$HOME/.vim/bin"
  "$HOME/.vim/vendor/bin"
  "$HOME/.yarn/bin"
  "$HOME/.config/yarn/global/node_modules/.bin"
  "$HOME/.cargo/bin"
  "$HOME/.vim/node_modules/.bin"
  /usr/local/bin
  $path
)

# -------------------------------------------------
# Magento Cloud CLI
# -------------------------------------------------
path=(
  "$HOME/.magento-cloud/bin"
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
  [[ -o interactive ]] && printf "Loading ..... %s\n" "$HOME/.profile"
  source "$HOME/.profile"
fi

# -------------------------------------------------
# Profiling (must be last)
# -------------------------------------------------
if [[ "$ZPROF" = true ]]; then
  zprof
fi
