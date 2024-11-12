#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
    set -x # You refer to a noisy script.(Used to debugging)
    shift
fi

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if [ "$(uname -s)" == 'Darwin' ]; then
    brew install gnupg2 git-flow zsh-completions
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
echo "Git configuration started on $(date +%Y%m%d%H%M%S)"
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
git config --global user.name "Vallabhdas Kansagara"
git config --global user.signingkey 8BA6E7ABD8112B3E

git config --global alias.add-unmerged '!f() { git diff --name-status --diff-filter=U | cut -f2 ; }; git add `f`'
git config --global alias.br branch
git config --global alias.cam 'commit -a -m'
git config --global alias.cas 'commit -a -s'
git config --global alias.casm 'commit -a -s -m'
git config --global alias.cb 'checkout -b'
git config --global alias.cf 'config --list'
git config --global alias.ci commit
git config --global alias.cm 'commit -m'
git config --global alias.co checkout
git config --global alias.conflicts 'diff --name-only --diff-filter=U'
git config --global alias.cs 'commit -S -v '
git config --global alias.csm 'commit -s -m'
git config --global alias.current 'rev-parse --verify HEAD'
git config --global alias.dv 'difftool -t vimdiff -y'
git config --global alias.edit-unmerged '!f() { git diff --name-status --diff-filter=U | cut -f2 ; }; vim `f`'
git config --global alias.fa 'fetch --all'
git config --global alias.gam 'am'
git config --global alias.gama 'am --abort'
git config --global alias.gamc 'am --continue'
git config --global alias.gams 'am --skip'
git config --global alias.gamscp 'am --show-current-patch'
git config --global alias.gb 'branch'
git config --global alias.gba 'branch -a'
git config --global alias.gbd 'branch -d'
git config --global alias.gbr 'branch --remote'
git config --global alias.gc 'commit -v '
git config --global alias.gc 'gc --prune=now --aggressive'
git config --global alias.gcF 'commit -v --amend'
git config --global alias.gca 'commit -v -a'
git config --global alias.gcaF 'commit -v -a --amend'
git config --global alias.gcanF 'commit -v -a --no-edit --amend'
git config --global alias.gcansF 'commit -v -a -s --no-edit --amend'
git config --global alias.gcnF 'commit -v --no-edit --amend'
git config --global alias.l 'pull'
git config --global alias.last 'log -1 HEAD --stat'
git config --global alias.lg 'log --stat'
git config --global alias.lgg 'log --graph'
git config --global alias.lgga 'log --graph --decorate --all'
git config --global alias.lgm 'log --graph --max-count=10'
git config --global alias.lgp 'log --stat -p'
git config --global alias.ll 'log --oneline'
git config --global alias.lo 'log --oneline --decorate'
git config --global alias.lod "log --graph --pretty '%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
git config --global alias.lods "log --graph --pretty '%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short"
git config --global alias.log 'log --oneline --decorate --graph'
git config --global alias.loga 'log --oneline --decorate --graph --all'
git config --global alias.lol "log --graph --pretty '%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'"
git config --global alias.lola "log --graph --pretty '%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all"
git config --global alias.lols "log --graph --pretty '%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat"
git config --global alias.ls 'config --global -l'
git config --global alias.lsIgnored 'ls-files . --ignored --exclude-standard --others'
git config --global alias.lsUntracked 'ls-files . --ignored --exclude-standard --others'
git config --global alias.meCommit 'rev-list --count'
git config --global alias.myGitLog " log --oneline | fzf --preview 'git show --name-only {1}'"
git config --global alias.myGitLs 'for i in */; do (cd $i && echo -n "$(pwd) <=> " && git rev-parse --abbrev-ref HEAD);  done'
git config --global alias.p 'push -u origin HEAD --force-with-lease'
git config --global alias.p 'push'
git config --global alias.pd 'push --dry-run'
git config --global alias.personal 'config --global user.email vrkansagara@gmail.com'
git config --global alias.personalLocal 'config user.email vrkansagara@gmail.com'
git config --global alias.personalLocalSign 'config user.signingkey 8BA6E7ABD8112B3E'
git config --global alias.personalSign 'config --global user.signingkey 8BA6E7ABD8112B3E'
git config --global alias.pf 'push --force-with-lease'
git config --global alias.pfF 'push --force'
git config --global alias.poat 'push origin --all && git push origin --tags'
git config --global alias.pr 'pull --rebase'
git config --global alias.pu 'push upstream'
git config --global alias.pushLog 'diff --stat --cached origin/main'
git config --global alias.pv 'push -v'
git config --global alias.r 'remote'
git config --global alias.ra 'remote add'
git config --global alias.rb 'rebase'
git config --global alias.rba 'rebase --abort'
git config --global alias.rbc 'rebase --continue'
git config --global alias.rbd 'rebase $(git_develop_branch)'
git config --global alias.rbi 'rebase -i'
git config --global alias.rbm 'rebase $(git_main_branch)'
git config --global alias.rbo 'rebase --onto'
git config --global alias.rbs 'rebase --skip'
git config --global alias.resetClean 'clean -fd'
git config --global alias.resetHardHEAD 'reset --hard HEAD'
git config --global alias.rev 'revert'
git config --global alias.rh 'reset'
git config --global alias.rhh 'reset --hard'
git config --global alias.rm 'rm'
git config --global alias.rmc 'rm --cached'
git config --global alias.rmv 'remote rename'
git config --global alias.roh 'reset origin/$(git_current_branch) --hard'
git config --global alias.rrm 'remote remove'
git config --global alias.rs 'restore'
git config --global alias.rset 'remote set-url'
git config --global alias.rss 'restore --source'
git config --global alias.rst 'restore --staged'
git config --global alias.rt 'cd "$(git rev-parse --show-toplevel || echo .)"'
git config --global alias.ru 'reset --'
git config --global alias.rup 'remote update'
git config --global alias.rv 'remote -v'
git config --global alias.rv 'remote -v'
git config --global alias.sb 'status -sb'
git config --global alias.sd 'svn dcommit'
git config --global alias.sh 'show'
git config --global alias.si 'submodule init'
git config --global alias.sps 'show --pretty=short --show-signature'
git config --global alias.sr 'svn rebase'
git config --global alias.ss 'status -s'
git config --global alias.ss 'status -v'
git config --global alias.st 'status -sb'
git config --global alias.st 'status'
git config --global alias.stashAdd "stash push -m 'Save at - $(date +%Y%m%d%H%M%S)'"
git config --global alias.stashApply "stash apply stash@{0}"
git config --global alias.stashList 'stash list --pretty=format:"%C(red)%h%C(reset) - %C(dim yellow)(%C(bold magenta)%gd%C(dim yellow))%C(reset) %<(70,trunc)%s %C(green)(%cr) %C(bold blue)<%an>%C(reset)"'
git config --global alias.undo 'reset --soft HEAD~1'
git config --global alias.undoRemove 'reset --hard HEAD~1'
git config --global alias.unstage 'reset HEAD --'
git config --global alias.visual '!gitk'
git config --global alias.wch 'whatchanged -p --abbrev-commit --pretty=medium'
git config --global alias.wip 'add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
git config --global alias.work 'config --global user.email v.kansagara@easternenterprise.com'
git config --global alias.workLocal 'config user.email v.kansagara@easternenterprise.com'
git config --global alias.workLocalSign 'config user.signingkey 9E1BB86EF02A2BAB'
git config --global alias.workSign 'config --global  user.signingkey 9E1BB86EF02A2BAB'

# Tee command append to file multiple time TODO
cat .gitignore | tee /tmp/.gitignore-global >/dev/null
sed 's/\r//' /tmp/.gitignore-global | sort -u > ~/.gitignore