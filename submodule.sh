!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo " "
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

remove_submodule(){
	read -r -p 'Do you want to remove git modules[Y/n]?' input
case $input in [yY][eE][sS]|[yY])
	echo "Install desktop manager"
	${SUDO} chown $USER -Rf .
	rm -rf .git --depth=1 modules
	touch .git --depth=1 modules
	rm -rf ./.git --depth=1 /modules/*
	;;
[nN][oO]|[nN])
	echo "Skipping...Removal of git sub module"
	;;
*)
	echo "Invalid input..."
	exit 1
	;;
esac
}

echo "Sub-module installation started at $CURRENT_DATE"
CLONE_DIRECTORY="$HOME/.vim/pack/vendor/start/"
remove_vim_vendor_module(){
	read -r -p 'Do you want to remove VIM vendor,php copmoser, coc vendor [Y/n]?' input
case $input in [yY][eE][sS]|[yY])
${SUDO} rm -rf ~/.config/coc
${SUDO} rm -rf vendor/*
${SUDO} rm -rf ${CLONE_DIRECTORY}/*
	;;
[nN][oO]|[nN])
	echo "Skipping...Removal of git sub module"
	;;
*)
	echo "Invalid input..."
	exit 1
	;;
esac
}

remove_vim_vendor_module
mkdir -p ${CLONE_DIRECTORY}
cd ${CLONE_DIRECTORY}

echo "Installation of [ commentary.vim: comment stuff out    ] ..."
git clone https://github.com/tpope/vim-commentary.git --depth=1

echo "Installation of [ surround.vim: quoting/parenthesizing made simple ] ..."
git clone https://github.com/tpope/vim-surround.git --depth=1

echo "Installation of [ fugitive.vim: A Git wrapper so awesome, it should be illegal  ] ..."
git clone https://github.com/tpope/vim-fugitive.git --depth=1

# As CtrlP is the 100% vim so no need extra burden of plugin and shell library
echo "Installation of [Active fork of kien/ctrlp.vim—Fuzzy file, buffer, mru, tag, etc finder. ] ..."
git clone https://github.com/ctrlpvim/ctrlp.vim.git --depth=1

echo "Installation of [Vim plugin for the Perl module / CLI script 'ack']"
git clone https://github.com/mileszs/ack.vim.git --depth=1

echo "Installation of [ Nodejs extension host for vim & neovim, load extensions like VSCode and host language servers. ] ..."
git clone --branch release https://github.com/neoclide/coc.nvim.git --depth=1

echo "Installation of [ A Vim plugin which shows git diff markers in the sign column and stages/previews/undoes hunks and partial hunks. ] ..."
git clone https://github.com/airblade/vim-gitgutter.git --depth=1

echo "Installation of [ Multiple cursors plugin for vim/neovim ] ..."
git clone https://github.com/mg979/vim-visual-multi.git --depth=1

echo "Installation of [ lean & mean status/tabline for vim that's light as air  ] ..."
git clone https://github.com/vim-airline/vim-airline.git --depth=1
git clone https://github.com/vim-airline/vim-airline-themes.git --depth=1

echo "Installation of [ types "use" statements for you ] ..."
git clone git@github.com:arnaud-lb/vim-php-namespace.git --depth=1

# echo "Installation of [ A Vim plugin for Prettier ] ..."
# git clone git@github.com:prettier/vim-prettier.git --depth=1
# cd ${CLONE_DIRECTORY}/vim-prettier
# yarn
# cd ${CLONE_DIRECTORY}

# echo "Installation of [ pathogen.vim: manage your runtimepath ] ..."
# git clone https://github.com/tpope/vim-pathogen.git --depth=1
# echo "Installation of [ Light & Dark Vim color schemes inspired by Google's Material Design  ] ..."
# git clone https://github.com/NLKNguyen/papercolor-theme.git --depth=1

echo "Installation of [ A tree explorer plugin for vim. ] ..."
git clone https://github.com/preservim/nerdtree.git --depth=1

# echo "Installation of [ sensible.vim: Defaults everyone can agree on   ] ..."
# git clone https://github.com/tpope/vim-sensible.git --depth=1  vendor/vim-sensible

# echo "Installation of [ scriptease.vim: A Vim plugin for Vim plugins    ] ..."
# git clone https://github.com/tpope/vim-scriptease.git --depth=1  vendor/vim-scriptease

# echo "Installation of [ Markdown for Vim: a complete environment to create Markdown files with a syntax highlight that doesn't suck!  ] ..."
# git clone https://github.com/gabrielelana/vim-markdown.git --depth=1  vendor/vim-markdown

# echo "Installation of [ vim-snipmate default snippets (Previously snipmate-snippets) ] ..."
# # git clone https://github.com/tomtom/tlib_vim.git --depth=1  vendor/tlib_vim
# # git clone https://github.com/MarcWeber/vim-addon-mw-utils.git --depth=1  vendor/vim-addon-mw-utils
# # git clone https://github.com/garbas/vim-snipmate.git --depth=1  vendor/vim-snipmate
# # git clone https://github.com/honza/vim-snippets.git --depth=1  vendor/vim-snippets

# echo "ultisnips is based on python( I like minimal configuration ) "
# git clone https://github.com/SirVer/ultisnips vendor/ultisnips


# echo "Installation of [A filetype plugin for VIM to help edit XML files ] ..."
# # git clone https://github.com/sukima/xmledit vendor/xmledit

# Unwanted / Disabled modules
# echo "Installation of [Automatically opens popup menu for completions ] ..."
# # git clone https://github.com/vim-scripts/AutoComplPop vendor/AutoComplPop

# echo "Installation of [ Perform all your vim insert mode completions with Tab ] ..."
# # git clone https://github.com/ervandew/supertab vendor/supertab

# echo "Installation of [  emmet for vim: http://emmet.io/ ] ..."
# # git clone https://github.com/mattn/emmet-vim.git --depth=1  vendor/emmet-vim

# echo "Installation of [ Go development plugin for Vim ] ..."
# # git clone https://github.com/fatih/vim-go.git --depth=1  vendor/vim-go

# # #git clone https://github.com/junegunn/goyo.vim bundle/goyo.vim
# # #git clone https://github.com/amix/vim-zenroom2 bundle/vim-zenroom2

# echo "Installation of [ A command-line fuzzy finder   ] ..."
# git clone-f  https://github.com/junegunn/fzf vendor/fzf
# echo "Installation of [ fzf heart vim  ] ..."
# git clone-f  https://github.com/junegunn/fzf.vim vendor/fzf.vim

cd "$HOME/.vim"

git submodule update --init --recursive --jobs 4  --remote --merge

bin/composer2 self-update
# bin/composer install --prefer-dist --no-scripts --no-progress --no-interaction  --no-dev
bin/composer2 update

cd $HOME/.vim/pack/vendor/start/coc.nvim
${SUDO} npm i -g npm@latest intelephense@latest livereloadx
npm i
# npm run build

# update coc-nvim plugines
# echo "Wait for 2 minutes, coc-nvim plugines is started updating"
# vim -c 'CocUpdateSync|q'
# npm install -g yarn
# yarn set version latest

echo "Submodule installation recursive dependence .....................[DONE]."

exit 0
