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
#  Note		  :- Linux /tmp directory permission, Linux way !
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

sudo chmod 1777 /tmp
find /tmp \
     -mindepth 1 \
     -name '.*-unix' -exec sudo chmod 1777 {} + -prune -o \
     -exec sudo chmod go-rwx {} +

echo "[DONE] Linux home directory permission applied."

exit 0
