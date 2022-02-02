#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo ""
export DEBIAN_FRONTEND=noninteractive
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
SCRIPT=$(readlink -f "")
SCRIPTDIR=$(dirname "$SCRIPT")

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


${SUDO} apt-get install --no-install-recommends -y gnupg2  git-flow

BASEDIR=$(dirname "$0")
cd $BASEDIR

# Run script to local directory
echo "Current directory is $(pwd)"
mv $HOME/.gitconfig /tmp

# Git config list
echo "Git configuration started on ${CURRENT_DATE}"
git config --global commit.gpgsign true
git config --global core.editor vim
git config --global core.excludesFile '~/.gitignore'
git config --global core.fileMode false
git config --global credential.helper store
git config --global diff.tool vimdiff
git config --global gpg.program gpg
git config --global help.autocorrect 0
git config --global init.defaultBranch master
git config --global merge.conflictstyle diff3
git config --global merge.tool vimdiff
git config --global mergetool.prompt false
git config --global pull.rebase false
git config --global user.name "Vallabh Kansagara"
git config --global user.signingkey 8BA6E7ABD8112B3E

git config --global alias.add-unmerged  '!f() { git diff --name-status --diff-filter=U | cut -f2 ; }; git add `f`'
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.cm 'commit -m'
git config --global alias.co checkout
git config --global alias.conflicts 'diff --name-only --diff-filter=U'
git config --global alias.current 'rev-parse --verify HEAD'
git config --global alias.dv 'difftool -t vimdiff -y'
git config --global alias.edit-unmerged '!f() { git diff --name-status --diff-filter=U | cut -f2 ; }; vim `f`'
git config --global alias.gc 'gc --prune=now --aggressive'
git config --global alias.last 'log -1 HEAD --stat'
git config --global alias.ll 'log --oneline'
git config --global alias.ls 'config --global -l'
git config --global alias.lsIgnored 'ls-files . --ignored --exclude-standard --others'
git config --global alias.lsUntracked 'ls-files . --ignored --exclude-standard --others'
git config --global alias.meCommit 'rev-list --count'
git config --global alias.personal 'config user.email vrkansagara@gmail.com'
git config --global alias.pushLog 'diff --stat --cached origin/master'
git config --global alias.resetClean 'clean -fd'
git config --global alias.resetHardHEAD 'reset --hard HEAD'
git config --global alias.rv 'remote -v'
git config --global alias.st 'status -sb'
git config --global alias.stashList 'stash list --pretty=format:"%C(red)%h%C(reset) - %C(dim yellow)(%C(bold magenta)%gd%C(dim yellow))%C(reset) %<(70,trunc)%s %C(green)(%cr) %C(bold blue)<%an>%C(reset)"'
git config --global alias.undo 'reset --soft HEAD~1'
git config --global alias.undoRemove 'reset --hard HEAD~1'
git config --global alias.unstage 'reset HEAD --'
git config --global alias.visual '!gitk'
git config --global alias.work 'config --global user.email vallabh.kansagara@commercepundit.com'
git config --global alias.workLocal 'config user.email vallabh.kansagara@commercepundit.com'

# Tee command append to file multiple time TODO
cat .gitignore | tee /tmp/.gitignore-global > /dev/null
sed 's/\r//' /tmp/.gitignore-global | sort -u > ~/.gitignore
