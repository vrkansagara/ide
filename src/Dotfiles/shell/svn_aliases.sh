# ==============================================================================
# svn_aliases.sh — Subversion (SVN) shortcut aliases
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# Usage      : source this file from ~/.bashrc or ~/.zshrc

# Guard against double-sourcing
[ -n "${_LOADED_SVN_ALIASES_SH:-}" ] && return 0
_LOADED_SVN_ALIASES_SH=1

# ------------------------------------------------------------------------------
# Core SVN aliases (sorted alphabetically by alias name)
# ------------------------------------------------------------------------------
alias s='svn'
alias saa='svn add * --force'                        # add all unversioned files
alias sc='svn checkout'
alias sci='svn ci -m'                                # check in with commit message
alias sco='svn co --ignore-externals'                # checkout, ignore externals
alias sd='svn diff -r'                               # diff; pass e.g.: 168:169 index.xml
alias si='svn info'                                  # info about local and remote state
alias sl='svn log --limit'                           # log; pass number to limit revisions
alias slf='svn log --verbose | grep'                 # search svn log for relevant info
alias sm='svn st -u'                                 # status of locally modified files
alias sr='svn info | grep Revision: | cut -c11-'
alias su='svn up --ignore-externals'                 # update, ignore externals

# ------------------------------------------------------------------------------
# Hard reset — interactive: reverts all local changes after confirmation
# svn status --show-updates --depth infinity | awk '{print $NF}' | \
#   xargs -I '{}' svn revert '{}'
# ------------------------------------------------------------------------------
alias s.HardReset='read -p "destroy all local changes?[y/N]" && [[ $REPLY =~ ^[yY] ]] && svn revert . -R && svn status | awk '"'"'/^\?/{print $2}'"'"' | xargs -r rm -rf'
