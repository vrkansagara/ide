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


export FILTER_BRANCH_SQUELCH_WARNING=1

git filter-branch --env-filter '
OLD_EMAIL="vallabh@vrkansagara.local"
CORRECT_EMAIL="vrkansagara@gmail.com"
CORRECT_NAME="Vallabh Kansagara"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
export GIT_COMMITTER_NAME="$CORRECT_NAME"
export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
# git commit-tree -S "$@";
fi

if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
export GIT_AUTHOR_NAME="$CORRECT_NAME"
export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
# git commit-tree -S "$@";
fi

' --tag-name-filter cat -- --branches --tags
# ' -- --all
