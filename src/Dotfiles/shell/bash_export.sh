# If you come from bash you might have to change your $PATH.
export PATH="$HOME/bin:$HOME/.vim/bin:$HOME/.vim/vendor/bin:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export JAVA_AWT_WM_NONREPARENTING=1

# BEGIN SNIPPET: Magento Cloud CLI configuration
HOME=${HOME:-'/home/vallabh'}
export PATH="$HOME/"'.magento-cloud/bin':"$PATH"
if [ -f "$HOME/"'.magento-cloud/shell-config.rc' ]; then . "$HOME/"'.magento-cloud/shell-config.rc'; fi 
# END SNIPPET

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# GPG Common problem solving
export GPG_TTY=$(tty)

# VIM plugines debug
export NVIM_COC_LOG_LEVEL=debug
export NVIM_COC_LOG_FILE=/tmp/coc-nvim.log

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
   export EDITOR='vim'
fi
