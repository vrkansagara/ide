#!/usr/bin/env bash

set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

# This directory name must not start with .vim
BACKUP_DIRECTORY="${HOME}/.old/vim-${CURRENT_DATE}"
CLONE_DIRECTORY="/tmp/.vim-${CURRENT_DATE}"

echo "Creating backup directory."
if [ ! -d "$BACKUP_DIRECTORY" ]; then
	mkdir -p $BACKUP_DIRECTORY
fi

echo "Creating backup of ~/.vim* to ${BACKUP_DIRECTORY}"
if [ $(ls $HOME/.vim* | wc -l) != 0 ]; then
	echo "Moving base vimrc config to back up folder"
	mv -f $HOME/.vim*  $BACKUP_DIRECTORY
fi

echo "Cloning the [vrkansagar] vim configuration."
git clone --recursive --branch master --depth 1 https://github.com/vrkansagara/ide.git ${CLONE_DIRECTORY}
cd ${CLONE_DIRECTORY}

# git pull --recurse-submodules
git submodule update --init --recursive
mv ${CLONE_DIRECTORY} $HOME/.vim

echo "Set up pathogen for vim run time path."
mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

echo "Adding symbolic link for better git tracking of project"
ln -s $HOME/.vim/vimrc.vim $HOME/.vimrc
ln -s $HOME/.vim/src/Dotfiles/zshrc $HOME/.zshrc
mv $HOME/.vim/coc-settings.json.dist $HOME/.vim/coc-settings.json

# Set sh and bin  directory executable
${SUDO} chmod -R +x $HOME/.vim/src/sh/* $HOME/.vim/bin

# Before leaving the script reset to current working directory
cd $HOME

echo "Installed the Ultimate Vim configuration of [vrkansagara] successfully! Enjoy :-)"
