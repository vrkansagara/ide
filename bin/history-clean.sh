#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- clean your bas history.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
$SHELL -c 'cat /dev/null > $HOME/.bash_history'
$SHELL -c 'cat /dev/null > $HOME/.zsh_history'
history -cw

exit 0
