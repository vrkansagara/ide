#!/usr/bin/env bash
set -euo pipefail

# Enable verbose mode: ./script.sh -v
if [[ "${1:-}" == "-v" ]]; then
  set -x
  shift
fi

# -------------------------------------------------
# Sudo handling
# -------------------------------------------------
sudo_cmd=""
if [[ "$(id -u)" -ne 0 ]]; then
  sudo_cmd="sudo"
fi

# -------------------------------------------------
# Script directory (safe)
# -------------------------------------------------
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
  if ! command -v brew >/dev/null 2>&1; then
    echo "❌ Homebrew not found. Install from https://brew.sh"
    exit 1
  fi
  brew install gnupg git-flow zsh-completions
else
  export DEBIAN_FRONTEND=noninteractive
  $sudo_cmd apt-get update -y
  $sudo_cmd apt-get install --no-install-recommends -y \
    gnupg2 \
    git-flow \
    ca-certificates
fi

# -------------------------------------------------------------------------
# Backup existing global gitconfig
# -------------------------------------------------------------------------
if [[ -f "$HOME/.gitconfig" ]]; then
  TS="$(date +%Y%m%d%H%M%S)"
  echo "Backing up ~/.gitconfig → ~/.gitconfig.backup.$TS"
  mv "$HOME/.gitconfig" "$HOME/.gitconfig.backup.$TS"
fi

# -------------------------------------------------------------------------
# Git configuration
# -------------------------------------------------------------------------
echo "Applying Git configuration ($(date))..."
add_config() {
  local name key value

  if [ "$#" -ne 3 ]; then
    echo "Usage: add_config <alias> <config.key> <value>" >&2
    return 1
  fi

  name="$1"
  key="$2"
  value="$3"

  # Escape value safely for git alias
  value=${value//\"/\\\"}

  git config --global alias."$name" \
    "config --global $key \"$value\""
}


git config --global commit.gpgsign true
git config --global core.editor "vim"
git config --global core.excludesFile "$HOME/.gitignore"
git config --global core.fileMode false
git config --global credential.helper "store"   # ⚠️ plaintext storage
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

# Warn if GPG key is missing
if ! gpg --list-secret-keys 8BA6E7ABD8112B3E >/dev/null 2>&1; then
  echo "⚠️  Warning: GPG key 8BA6E7ABD8112B3E not found locally"
fi

# Profile switching
add_config personal user.email vrkansagara@gmail.com
add_config work user.email v.kansagara@easternenterprise.com

# -------------------------------------------------------------------------
# Git aliases (cleaned & safe)
# -------------------------------------------------------------------------
add_alias() {
  git config --global alias."$1" "$2"
}

add_alias add-unmerged '!git diff --name-only --diff-filter=U | xargs -r git add'
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
add_alias edit-unmerged '!git diff --name-only --diff-filter=U | xargs -r vim'
add_alias fa 'fetch --all'
add_alias gb 'branch'
add_alias gba 'branch -a'
add_alias gbd 'branch -d'
add_alias gbr 'branch --remote'
add_alias gs 'log -1 --show-signature'

# FIXED: gc alias (no recursion)
add_alias gc '!git reflog expire --expire=now --all && git gc --prune=now --aggressive'

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
add_alias rv 'remote -v'

# Stash aliases (shell-safe)
add_alias stashAdd '!sh -c "git stash push -m \"Save at - $(date +%Y%m%d%H%M%S)\""'
add_alias stashApply 'stash apply stash@{0}'
add_alias stashList 'stash list'



# -------------------------------------------------------------------------
# Global Gitignore
# -------------------------------------------------------------------------
if [[ -f ".gitignore" ]]; then
  echo "Generating ~/.gitignore..."
  sed 's/\r//' ".gitignore" | sort -u > "$HOME/.gitignore"
fi

echo "✅ Git configuration completed successfully."
exit 0
