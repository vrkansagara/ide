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
#  Note		  :- Installation script for my editor (IDE/VIM).
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# This directory name must not start with .vim
BACKUP_DIRECTORY="${HOME}/.old/vim-${CURRENT_DATE}"
CLONE_DIRECTORY="/tmp/.vim-${CURRENT_DATE}"

echo "Creating backup directory."
if [ ! -d "$BACKUP_DIRECTORY" ]; then
	mkdir -p $BACKUP_DIRECTORY
fi

echo "Cloning the [vrkansagara/ide] vim configuration."
git clone --recursive --branch master --depth 1 git@github.com:vrkansagara/ide.git ${CLONE_DIRECTORY}
cd ${CLONE_DIRECTORY}

echo "Creating backup of ~/.vim* to ${BACKUP_DIRECTORY}"
if [ $(ls $HOME/.vim* | wc -l) != 0 ]; then
	echo "Moving base vimrc config to back up folder"
	mv -f $HOME/.vim*  $BACKUP_DIRECTORY
fi

# git pull --recurse-submodules
# git submodule update --init --recursive
mv ${CLONE_DIRECTORY} $HOME/.vim
mkdir -p "$HOME/.vim/pack/vendor/start/"
sh -c "$HOME/.vim/submodule.sh"

# echo "Set up pathogen for vim run time path."
# mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

echo "Adding symbolic link for better git tracking of project"
${SUDO} mv .zshrc .vimrc .bashrc /tmp
${SUDO} mv $HOME/.vim/coc-settings.dist.json $HOME/.vim/coc-settings.json
[ -f $HOME/.zshrc ] mv $HOME/.zshrc $HOME/.zshrc.old
ln -s $HOME/.vim/src/Dotfiles/zshrc $HOME/.zshrc
ln -s $HOME/.vim/vimrc.vim $HOME/.vimrc
ln -s $HOME/.vim/src/Dotfiles/bashrc $HOME/.bashrc
ln -s $HOME/.vim/src/Sh/Git/hooks/pre-commit  $HOME/.vim/.git/hooks
mkdir -p $HOME/.vim/data/cache/zsh

# Set sh and bin  directory executable
chmod -R +x $HOME/.vim/src/Sh/* $HOME/.vim/bin

# Before leaving the script reset to current working directory
cd $HOME

echo "Installed the Ultimate Vim configuration of [vrkansagara] successfully! Enjoy :-)"

exit 0
