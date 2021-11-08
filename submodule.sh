#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

SCRIPT=$(readlink -f "")
SCRIPTDIR=$(dirname "$SCRIPT")

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Set up script fot the ide project
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

echo " "
echo "Sub-module installation started at $CURRENT_DATE"

cd ~/.vim

read -r -p 'Do you want to remove git modules[Y/n]?' input
case $input in [yY][eE][sS]|[yY])
	echo "Install desktop manager"
	${SUDO} chown $USER -Rf .
	rm -rf .gitmodules
	touch .gitmodules
	rm -rf ./.git/modules/*
	;;
[nN][oO]|[nN])
	echo "Skipping...Removal of git sub module"
	;;
*)
	echo "Invalid input..."
	exit 1
	;;
esac

${SUDO} rm -rf bundle/*
${SUDO} rm -rf vendor/*

echo "Installation of [ pathogen.vim: manage your runtimepath ] ..."
git submodule add -f https://github.com/tpope/vim-pathogen.git vendor/vim-pathogen

echo "Installation of [ commentary.vim: comment stuff out    ] ..."
git submodule add -f  https://github.com/tpope/vim-commentary.git vendor/vim-commentry

echo "Installation of [ surround.vim: quoting/parenthesizing made simple ] ..."
git submodule add -f https://github.com/tpope/vim-surround.git vendor/vim-surround

echo "Installation of [ fugitive.vim: A Git wrapper so awesome, it should be illegal  ] ..."
git submodule add -f https://github.com/tpope/vim-fugitive.git vendor/fugitive

echo "Installation of [ Light & Dark Vim color schemes inspired by Google's Material Design  ] ..."
git submodule add -f https://github.com/NLKNguyen/papercolor-theme.git vendor/papercolor-theme

echo "Installation of [ A tree explorer plugin for vim. ] ..."
git submodule add -f https://github.com/preservim/nerdtree.git vendor/nerdtree

# As CtrlP is the 100% vim so no need extra burden of plugin and shell library
echo "Installation of [Active fork of kien/ctrlp.vim—Fuzzy file, buffer, mru, tag, etc finder. ] ..."
git submodule add -f https://github.com/ctrlpvim/ctrlp.vim.git vendor/ctrlp.vim

echo "Installation of [Vim plugin for the Perl module / CLI script 'ack']"
git submodule add -f https://github.com/mileszs/ack.vim.git vendor/ack.vim

echo "Installation of [ Nodejs extension host for vim & neovim, load extensions like VSCode and host language servers. ] ..."
git submodule add -f https://github.com/neoclide/coc.nvim.git vendor/coc.nvim

echo "Installation of [ A Vim plugin which shows git diff markers in the sign column and stages/previews/undoes hunks and partial hunks. ] ..."
git submodule add -f https://github.com/airblade/vim-gitgutter.git vendor/vim-gitgutter

echo "Installation of [ Multiple cursors plugin for vim/neovim ] ..."
git submodule add -f https://github.com/mg979/vim-visual-multi.git vendor/vim-visual-multi

echo "Installation of [ lean & mean status/tabline for vim that's light as air  ] ..."
git submodule add -f https://github.com/vim-airline/vim-airline.git vendor/vim-airline
git submodule add -f https://github.com/vim-airline/vim-airline-themes.git vendor/vim-airline-theme

# echo "Installation of [ sensible.vim: Defaults everyone can agree on   ] ..."
# git submodule add -f https://github.com/tpope/vim-sensible.git vendor/vim-sensible

# echo "Installation of [ scriptease.vim: A Vim plugin for Vim plugins    ] ..."
# git submodule add -f https://github.com/tpope/vim-scriptease.git vendor/vim-scriptease

# echo "Installation of [ Markdown for Vim: a complete environment to create Markdown files with a syntax highlight that doesn't suck!  ] ..."
# git submodule add -f https://github.com/gabrielelana/vim-markdown.git vendor/vim-markdown

# echo "Installation of [ vim-snipmate default snippets (Previously snipmate-snippets) ] ..."
# # git submodule add -f https://github.com/tomtom/tlib_vim.git vendor/tlib_vim
# # git submodule add -f https://github.com/MarcWeber/vim-addon-mw-utils.git vendor/vim-addon-mw-utils
# # git submodule add -f https://github.com/garbas/vim-snipmate.git vendor/vim-snipmate
# # git submodule add -f https://github.com/honza/vim-snippets.git vendor/vim-snippets

# echo "ultisnips is based on python( I like minimal configuration ) "
# git submodule add -f https://github.com/SirVer/ultisnips vendor/ultisnips

# echo "Installation of [ types "use" statements for you ] ..."
# # git submodule add -f https://github.com/arnaud-lb/vim-php-namespace.git vendor/vim-php-namespace

# echo "Installation of [A filetype plugin for VIM to help edit XML files ] ..."
# # git submodule add -f https://github.com/sukima/xmledit vendor/xmledit

# Unwanted / Disabled modules
# echo "Installation of [Automatically opens popup menu for completions ] ..."
# # git submodule add -f https://github.com/vim-scripts/AutoComplPop vendor/AutoComplPop

# echo "Installation of [ Perform all your vim insert mode completions with Tab ] ..."
# # git submodule add -f https://github.com/ervandew/supertab vendor/supertab

# echo "Installation of [  emmet for vim: http://emmet.io/ ] ..."
# # git submodule add -f https://github.com/mattn/emmet-vim.git vendor/emmet-vim

# echo "Installation of [ Go development plugin for Vim ] ..."
# # git submodule add -f https://github.com/fatih/vim-go.git vendor/vim-go

# # #git submodule add -f https://github.com/junegunn/goyo.vim bundle/goyo.vim
# # #git submodule add -f https://github.com/amix/vim-zenroom2 bundle/vim-zenroom2

# echo "Installation of [ A command-line fuzzy finder   ] ..."
# git submodule add -f  https://github.com/junegunn/fzf vendor/fzf
# echo "Installation of [ fzf heart vim  ] ..."
# git submodule add -f  https://github.com/junegunn/fzf.vim vendor/fzf.vim

git submodule update --init --recursive --jobs 4  --remote --merge

bin/composer2 self-update
# bin/composer install --prefer-dist --no-scripts --no-progress --no-interaction  --no-dev
bin/composer2 update

${SUDO} rm -rf ~/.config/coc
cd vendor/coc.nvim
${SUDO} npm i -g npm@latest
${SUDO} npm i -g intelephense@latest
npm i
npm run build

# update coc-nvim plugines
# echo "Wait for 2 minutes, coc-nvim plugines is started updating"
# vim -c 'CocUpdateSync|q'
# npm install -g yarn
# yarn set version latest

echo "Submodule installation recursive dependence .....................[DONE]."

exit 0
