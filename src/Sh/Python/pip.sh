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
#  Note		  :- Pip installation script.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

cd /tmp
rm -rf get-pip.py

wget https://bootstrap.pypa.io/get-pip.py
${SUDO} $(which python3) get-pip.py
$(which python3) -m pip install -U setuptools
${SUDO} apt-get install python3-pip

pip --help
