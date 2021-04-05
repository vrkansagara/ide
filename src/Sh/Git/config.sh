#!/usr/bin/env bash
set -e

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
BASEDIR=$(dirname "$0")

cd $BASEDIR
# Run script to local directory
echo "Current directory is $(pwd)"

echo "Git configuration started on ${CURRENT_DATE}"
# Git config list

git config --global core.editor vim
git config --global core.fileMode false


# git config --global diff.external "/usr/bin/meld"
git config --global diff.tool vimdiff

git config --global user.name "Vallabh Kansagara"
git config --global help.autocorrect 0
git config --global credential.helper store

git config --global alias.ls 'config --global -l'
git config --global alias.ll 'log --oneline'
git config --global alias.undo 'reset --soft HEAD~1'
git config --global alias.undoRemove 'reset --hard HEAD~1'
git config --global alias.current 'rev-parse --verify HEAD'

git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

git config --global alias.last 'log -1 HEAD'
git config --global alias.last 'log -1 HEAD --stat'

git config --global alias.unstage 'reset HEAD --'


git config --global alias.st 'status -sb'
git config --global alias.visual '!gitk'
git config --global alias.dv 'difftool -t vimdiff -y'


git config --global alias.cm 'commit -m'
git config --global alias.rv 'remote -v'



# To count your commits is really easy and straightforward; here is the Git command:
git config --global alias.meCommit 'rev-list --count'

git config --global alias.gc 'gc --prune=now --aggressive'

git config --global alias.work 'config --global user.email vallabh.kansagara@commercepundit.com'
git config --global alias.workLocal 'config user.email vallabh.kansagara@commercepundit.com'
git config --global alias.personal 'config user.email vrkansagara@gmail.com'

git config --global core.excludesFile '~/.gitignore'
echo "Copying global .gitignore file for current user"
# Tee command append to file multiple time TODO
cat .gitignore | tee -a /tmp/.gitignore-global > /dev/null
sed 's/\r//' /tmp/.gitignore-global | sort -u > ~/.gitignore
