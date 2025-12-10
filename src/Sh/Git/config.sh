#!/usr/bin/env bash
set -euo pipefail

# Enable verbose mode: ./script.sh -v
if [[ "${1:-}" == "-v" ]]; then
  set -x
  shift
fi

# Sudo if needed
sudo_cmd=""
if [[ "$(id -u)" -ne 0 ]]; then
  sudo_cmd="sudo"
fi

# Script directory (POSIX-safe)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# -------------------------------------------------------------------------
#  Maintainer :- Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# -------------------------------------------------------------------------

echo "Running Git Agent Provisioner"
echo "Working directory: $SCRIPT_DIR"

# -------------------------------------------------------------------------
# Install Dependencies
# -------------------------------------------------------------------------
if [[ "$(uname -s)" == "Darwin" ]]; then
  brew install gnupg2 git-flow zsh-completions
else
  $sudo_cmd apt-get update -y
  $sudo_cmd apt-get install --no-install-recommends -y gnupg2 git-flow
fi

# -------------------------------------------------------------------------
# Backup existing global gitconfig safely
# -------------------------------------------------------------------------
if [[ -f "$HOME/.gitconfig" ]]; then
  TS="$(date +%Y%m%d%H%M%S)"
  echo "Backing up existing ~/.gitconfig → ~/.gitconfig.backup.$TS"
  mv "$HOME/.gitconfig" "$HOME/.gitconfig.backup.$TS"
fi

# -------------------------------------------------------------------------
# Start fresh Git configuration
# -------------------------------------------------------------------------
echo "Applying Git configuration ($(date))..."

git config --global commit.gpgsign true
git config --global core.editor "vim"
git config --global core.excludesFile "$HOME/.gitignore"
git config --global core.fileMode false
git config --global credential.helper "store"
git config --global diff.tool "vimdiff"
git config --global gpg.program "gpg"
git config --global help.autocorrect 0
git config --global http.postBuffer 524288000
git config --global init.defaultBranch main
git config --global merge.conflictstyle diff3
git config --global merge.tool "vimdiff"
git config --global mergetool.prompt false
git config --global pull.rebase false
git config --global url."https://".insteadOf "git://"
git config --global user.name "Vallabhdas Kansagara"
git config --global user.signingkey "8BA6E7ABD8112B3E"

# -------------------------------------------------------------------------
# Aliases (duplicates removed, corrected, POSIX-safe)
# -------------------------------------------------------------------------

add_alias() {
  git config --global alias."$1" "$2"
}

add_alias add-unmerged '!git diff --name-status --diff-filter=U | cut -f2 | xargs git add'
add_alias br 'branch'
add_alias cam 'commit -a -m'
add_alias cas 'commit -a -s'
add_alias casm 'commit -a -s -m'
add_alias cb 'checkout -b'
add_alias cf 'config --list'
add_alias ci 'commit'
add_alias cm 'commit -m'
add_alias co 'checkout'
add_alias conflicts 'diff --name-only --diff-filter=U'
add_alias cs 'commit -S -v'
add_alias csm 'commit -s -m'
add_alias current 'rev-parse --verify HEAD'
add_alias dv 'difftool -t vimdiff -y'
add_alias edit-unmerged '!git diff --name-status --diff-filter=U | cut -f2 | xargs vim'
add_alias fa 'fetch --all'
add_alias gb 'branch'
add_alias gba 'branch -a'
add_alias gbd 'branch -d'
add_alias gbr 'branch --remote'

# FIX: gc alias duplicated → keep the correct one
add_alias gc 'gc --prune=now --aggressive'

add_alias gca 'commit -v -a'
add_alias gcaF 'commit -v -a --amend'
add_alias gcanF 'commit -v -a --no-edit --amend'
add_alias gcansF 'commit -v -a -s --no-edit --amend'
add_alias gcnF 'commit -v --no-edit --amend'

add_alias lg 'log --stat'
add_alias lgg 'log --graph'
add_alias lgga 'log --graph --decorate --all'
add_alias log 'log --oneline --decorate --graph'
add_alias loga 'log --oneline --decorate --graph --all'
add_alias ll 'log --oneline'
add_alias lga 'log --graph --max-count=10'
add_alias lod "log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
add_alias lols "log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat"

add_alias pd 'push --dry-run'
add_alias p 'push'
add_alias pf 'push --force'
add_alias pfwl 'push --force-with-lease'
add_alias pofwl 'push -u origin HEAD --force-with-lease'
add_alias pr 'pull --rebase'
add_alias sb 'status -sb'
add_alias st 'status -sb'
add_alias undo 'reset --soft HEAD~1'
add_alias unstage 'reset HEAD --'

add_alias rv 'remote -v' # FIX: duplicated entry

add_alias stashAdd "!git stash push -m 'Save at - $(date +%Y%m%d%H%M%S)'"
add_alias stashApply 'stash apply stash@{0}'
add_alias stashList 'stash list --pretty=format:"%C(red)%h%C(reset) - %C(dim yellow)(%C(bold magenta)%gd%C(dim yellow))%C(reset) %<(70,trunc)%s %C(green)(%cr) %C(bold blue)<%an>%C(reset)"'

# Profile switching
add_alias personal 'config --global user.email vrkansagara@gmail.com'
add_alias work 'config --global user.email v.kansagara@easternenterprise.com'

# -------------------------------------------------------------------------
# Global Gitignore generation (sorted, cleaned)
# -------------------------------------------------------------------------
if [[ -f ".gitignore" ]]; then
  echo "Generating ~/.gitignore..."
  sed 's/\r//' ".gitignore" | sort -u > "$HOME/.gitignore"
fi

echo "Git configuration completed successfully."
exit 0
