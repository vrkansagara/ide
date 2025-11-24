#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

export CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export SCRIPT=$(readlink -f "")
export SCRIPTDIR=$(dirname "$SCRIPT")

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- https://tldp.org/LDP/abs/html/io-redirection.html
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

bold=$(tput bold)
normal=$(tput sgr0)
echo "this is ${bold}bold${normal} but this isn't"
