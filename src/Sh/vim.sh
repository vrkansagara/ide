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
${SUDO} apt-get install --no-install-recommends software-properties-common git make ncurses-dev build-essential  libncurses5-dev \
libgtk2.0-dev libatk1.0-dev \
libcairo2-dev python-dev \
python3-dev git

mkdir -p ~/tmp/latest
cd ~/tmp/latest
# git clone https://github.com/vim/vim.git --depth 1 ~/tmp/latest/vim
cd ~/tmp/latest/vim
git reset --hard HEAD
git clean -fd
./configure --enable-pythoninterp --prefix=/usr
make
${SUDO} make install

# ${SUDO} add-apt-repository -y ppa:jonathonf/vim
# ${SUDO} apt update
# ${SUDO} apt install -y --reinstall vim
