#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
    set -x # You refer to a noisy script.(Used to debugging)
fi

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if [ $(uname -s) == 'Darwin' ]; then
#    brew install gnupg2 git-flow zsh-completions
    brew install gnupg2 zsh-completions
else
    ${SUDO} apt-get install --no-install-recommends -y gnupg2 git-flow
fi

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
git config --global http.postBuffer 524288000
git config --global init.defaultBranch main
git config --global merge.conflictstyle diff3
git config --global merge.tool vimdiff
git config --global mergetool.prompt false
git config --global pull.rebase false
git config --global url."https://".insteadOf git://
git config --global user.name "Vallabh Kansagara"
git config --global user.signingkey 8BA6E7ABD8112B3E

git config --global alias.add-unmerged '!f() { git diff --name-status --diff-filter=U | cut -f2 ; }; git add `f`'
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.cm 'commit -m'
git config --global alias.co checkout
git config --global alias.conflicts 'diff --name-only --diff-filter=U'
git config --global alias.current 'rev-parse --verify HEAD'
git config --global alias.dv 'difftool -t vimdiff -y'
git config --global alias.edit-unmerged '!f() { git diff --name-status --diff-filter=U | cut -f2 ; }; vim `f`'
git config --global alias.gam='git am'
git config --global alias.gama='git am --abort'
git config --global alias.gamc='git am --continue'
git config --global alias.gams='git am --skip'
git config --global alias.gamscp='git am --show-current-patch'
git config --global alias.gb='git branch'
git config --global alias.gba='git branch -a'
git config --global alias.gbd='git branch -d'
git config --global alias.gbr='git branch --remote'
git config --global alias.gc 'gc --prune=now --aggressive'
git config --global alias.gc!='git commit -v --amend'
git config --global alias.gc='git commit -v '
git config --global alias.gca!='git commit -v -a --amend'
git config --global alias.gca='git commit -v -a'
git config --global alias.gcam='git commit -a -m'
git config --global alias.gcan!='git commit -v -a --no-edit --amend'
git config --global alias.gcans!='git commit -v -a -s --no-edit --amend'
git config --global alias.gcas='git commit -a -s'
git config --global alias.gcasm='git commit -a -s -m'
git config --global alias.gcb='git checkout -b'
git config --global alias.gcf='git config --list'
git config --global alias.gcn!='git commit -v --no-edit --amend'
git config --global alias.gcs='git commit -S -v '
git config --global alias.gcsm='git commit -s -m'
git config --global alias.gl='git pull'
git config --global alias.glg='git log --stat'
git config --global alias.glgg='git log --graph'
git config --global alias.glgga='git log --graph --decorate --all'
git config --global alias.glgm='git log --graph --max-count=10'
git config --global alias.glgp='git log --stat -p'
git config --global alias.glo='git log --oneline --decorate'
git config --global alias.glod="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
git config --global alias.glods="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short"
git config --global alias.glog='git log --oneline --decorate --graph'
git config --global alias.gloga='git log --oneline --decorate --graph --all'
git config --global alias.glol="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'"
git config --global alias.glola="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all"
git config --global alias.glols="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat"
git config --global alias.gp 'push -u origin HEAD --force-with-lease'
git config --global alias.gp='git push'
git config --global alias.gpd='git push --dry-run'
git config --global alias.gpf!='git push --force'
git config --global alias.gpf='git push --force-with-lease'
git config --global alias.gpoat='git push origin --all && git push origin --tags'
git config --global alias.gpr='git pull --rebase'
git config --global alias.gpu='git push upstream'
git config --global alias.gpv='git push -v'
git config --global alias.gr='git remote'
git config --global alias.gra='git remote add'
git config --global alias.grb='git rebase'
git config --global alias.grba='git rebase --abort'
git config --global alias.grbc='git rebase --continue'
git config --global alias.grbd='git rebase $(git_develop_branch)'
git config --global alias.grbi='git rebase -i'
git config --global alias.grbm='git rebase $(git_main_branch)'
git config --global alias.grbo='git rebase --onto'
git config --global alias.grbs='git rebase --skip'
git config --global alias.grev='git revert'
git config --global alias.grh='git reset'
git config --global alias.grhh='git reset --hard'
git config --global alias.grm='git rm'
git config --global alias.grmc='git rm --cached'
git config --global alias.grmv='git remote rename'
git config --global alias.groh='git reset origin/$(git_current_branch) --hard'
git config --global alias.grrm='git remote remove'
git config --global alias.grs='git restore'
git config --global alias.grset='git remote set-url'
git config --global alias.grss='git restore --source'
git config --global alias.grst='git restore --staged'
git config --global alias.grt='cd "$(git rev-parse --show-toplevel || echo .)"'
git config --global alias.gru='git reset --'
git config --global alias.grup='git remote update'
git config --global alias.grv='git remote -v'
git config --global alias.gsb='git status -sb'
git config --global alias.gsd='git svn dcommit'
git config --global alias.gsh='git show'
git config --global alias.gsi='git submodule init'
git config --global alias.gsps='git show --pretty=short --show-signature'
git config --global alias.gsr='git svn rebase'
git config --global alias.gss='git status -s'
git config --global alias.gst='git status'
git config --global alias.gwch='git whatchanged -p --abbrev-commit --pretty=medium'
git config --global alias.gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
git config --global alias.last 'log -1 HEAD --stat'
git config --global alias.ll 'log --oneline'
git config --global alias.ls 'config --global -l'
git config --global alias.lsIgnored 'ls-files . --ignored --exclude-standard --others'
git config --global alias.lsUntracked 'ls-files . --ignored --exclude-standard --others'
git config --global alias.meCommit 'rev-list --count'
git config --global alias.myGitLog="git log --oneline | fzf --preview 'git show --name-only {1}'"
git config --global alias.myGitLs='for i in */; do (cd $i && echo -n "$(pwd) <=> " && git rev-parse --abbrev-ref HEAD);  done'
git config --global alias.personal 'config --global user.email vrkansagara@gmail.com'
git config --global alias.personalLocal 'config user.email vrkansagara@gmail.com'
git config --global alias.personalLocalSign 'config user.signingkey 8BA6E7ABD8112B3E'
git config --global alias.personalSign 'config --global user.signingkey 8BA6E7ABD8112B3E'
git config --global alias.pushLog 'diff --stat --cached origin/main'
git config --global alias.resetClean 'clean -fd'
git config --global alias.resetHardHEAD 'reset --hard HEAD'
git config --global alias.rv 'remote -v'
git config --global alias.st 'status -sb'
git config --global alias.stashList 'stash list --pretty=format:"%C(red)%h%C(reset) - %C(dim yellow)(%C(bold magenta)%gd%C(dim yellow))%C(reset) %<(70,trunc)%s %C(green)(%cr) %C(bold blue)<%an>%C(reset)"'
git config --global alias.undo 'reset --soft HEAD~1'
git config --global alias.undoRemove 'reset --hard HEAD~1'
git config --global alias.unstage 'reset HEAD --'
git config --global alias.visual '!gitk'
git config --global alias.work 'config --global user.email v.kansagara@easternenterprise.com'
git config --global alias.workLocal 'config user.email v.kansagara@easternenterprise.com'
git config --global alias.workLocalSign 'config user.signingkey 9E1BB86EF02A2BAB'
git config --global alias.workSign 'config --global  user.signingkey 9E1BB86EF02A2BAB'

# Tee command append to file multiple time TODO
cat .gitignore | tee /tmp/.gitignore-global >/dev/null
sed 's/\r//' /tmp/.gitignore-global | sort -u >~/.gitignore