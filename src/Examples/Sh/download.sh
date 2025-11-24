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
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# Our custom function
cust_func() {
	wget -q "$1"
}

while IFS= read -r url; do
	cust_func "$url" &
done </tmp/list-download.txt

wait

echo "All files are downloaded."
