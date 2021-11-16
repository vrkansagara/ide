#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo " "
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt-get install curl 
# Using Linux
curl -sL install-node.now.sh/lts | ${SUDO} bash -
curl --compressed -o- -L https://yarnpkg.com/install.sh | ${SUDO} bash

# curl -fsSL https://deb.nodesource.com/setup_16.x | ${SUDO} -E bash -
# curl -fsSL https://deb.nodesource.com/setup_16.x | ${SUDO} bash -
# ${SUDO} apt-get install --yes --no-install-recommends  nodejs
