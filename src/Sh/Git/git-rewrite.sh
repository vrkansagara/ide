#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo -e ""
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


#git filter-branch [--env-filter <command>] [--tree-filter <command>]
#    [--index-filter <command>] [--parent-filter <command>]
#    [--msg-filter <command>] [--commit-filter <command>]
#    [--tag-name-filter <command>] [--subdirectory-filter <directory>]
#    [--prune-empty]
#    [--original <namespace>] [-d <directory>] [-f | --force]
#    [--] [<rev-list options>…]

# cd ~/.vim/
# cd ~/git/vrkansagara/dwm
cd ~/git/vrkansagara/LaraOutPress
export FILTER_BRANCH_SQUELCH_WARNING=1

update_signature(){
# vrkansagara gpg signature
# curl -sL https://gist.githubusercontent.com/vrkansagara/862e1ea96091ddf01d8e3f0786eefae8/raw/bcc458eb4b2c0eb441aaf7a56f385bc6cd4cb25a/vrkansagara.gpg | gpg --import
# 
# export GPGKEY=8BA6E7ABD8112B3E

git filter-branch --force --commit-filter '
if [ "$GIT_COMMITTER_EMAIL" = "vrkansagara@gmail.com" ];
then git commit-tree -S "$@";
else git commit-tree "$@";
fi

if [ "$GIT_AUTHOR_EMAIL" = "vrkansagara@gmail.com" ];
then git commit-tree -S "$@";
else git commit-tree "$@";
fi
' --tag-name-filter cat -- --branches --tags
# ' HEAD
}

update_email(){
	git filter-branch --env-filter '
OLD_EMAIL="vallabh@vrkansagara.local"
CORRECT_EMAIL="vrkansagara@gmail.com"
CORRECT_NAME="Vallabh Kansagara"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
export GIT_COMMITTER_NAME="$CORRECT_NAME"
export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi

if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
export GIT_AUTHOR_NAME="$CORRECT_NAME"
export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
