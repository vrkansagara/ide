#!/usr/bin/env bash

# set -euxo pipefail # This setting is telling the script to exit on a command error.

if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

git_submodule_remove_untracked() {

  cd $HOME/.vim/
  for i in $(git ls-files --stage | grep 160000 | awk "{print \$4}"); do
    (
      git rm --cached -rf $i
    )
  done
}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

if [ "$(whoami)" != "root" ]; then
  # Check if sudo is installed
  command_exists sudo || return 1
  SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- VIM dependecies setup using git submodule + vim manager
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo "Sub-module installation started at $CURRENT_DATE"
VIM_DIRECTORY="$HOME/.vim/"
CLONE_DIRECTORY="$HOME/.vim/pack/vendor/start/"
CLONE_DIRECTORY_COLOR="$HOME/.vim/pack/colors/start/"
cd ${VIM_DIRECTORY}

remove_vim_vendor_module() {

  read -r -p 'Do you want to remove VIM vendor,php copmoser, coc vendor [Y/n]?' input
  case $input in [yY][eE][sS] | [yY])
    git_submodule_remove_untracked || return 1
    #${SUDO} rm -rf   $HOME/.config/coc

    ${SUDO} rm -rf \
      ${VIM_DIRECTORY}/vendor/* \
      ${VIM_DIRECTORY}/pack/* \
      ${VIM_DIRECTORY}/.gitmodules \
      ${VIM_DIRECTORY}/.git/modules/*
    ${SUDO} touch ${VIM_DIRECTORY}/.gitmodules
    ;;

  [nN][oO] | [nN])
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
mkdir -p ${CLONE_DIRECTORY_COLOR}

submodule() {

  ### (1) Colorscheme ###

  echo "Installation of [ Light & Dark Vim color schemes inspired by Google's Material Design  ] ..."
  git submodule add -f https://github.com/NLKNguyen/papercolor-theme.git pack/colors/start/papercolor-theme

  echo "Installation of [ A vim theme inspired by Atom's default dark theme   ] ..."
  git submodule add -f https://github.com/gosukiwi/vim-atom-dark.git pack/colors/start/vim-atom-dark

  echo "Installation of [ Primary, a Vim color scheme based on Google's colors    ] ..."
  git submodule add -f https://github.com/google/vim-colorscheme-primary.git pack/colors/start/vim-colorscheme-primary

  echo "Installation of [ Refined color, contains both gui and cterm256 for dark and light background    ] ..."
  git submodule add -f https://github.com/vim-scripts/peaksea.git pack/colors/start/peaksea

  ### (2) Lets do some file information using Light Line ###

  echo "Installation of [ A light and configurable statusline/tabline plugin for Vim     ] ..."
  git submodule add -f https://github.com/itchyny/lightline.vim.git pack/vendor/start/lightline

  echo "Installation of [ A tree explorer plugin for vim. ] ..."
  git submodule add -f https://github.com/preservim/nerdtree.git pack/vendor/start/nerdtree

  # As CtrlP is the 100% vim so no need extra burden of plugin and shell library
  echo "Installation of [Active fork of kien/ctrlp.vim—Fuzzy file, buffer, mru, tag, etc finder. ] ..."
  git submodule add -f https://github.com/ctrlpvim/ctrlp.vim.git pack/vendor/start/ctrlp

  echo "Installation of [ commentary.vim: comment stuff out    ] ..."
  git submodule add -f https://github.com/tpope/vim-commentary.git pack/vendor/start/vim-commentary

  echo "Installation of [ surround.vim: quoting/parenthesizing made simple ] ..."
  git submodule add -f https://github.com/tpope/vim-surround.git pack/vendor/start/vim-surround

  echo "Installation of [ fugitive.vim: A Git wrapper so awesome, it should be illegal  ] ..."
  git submodule add -f https://github.com/tpope/vim-fugitive.git pack/vendor/start/vim-fugitive

  echo "Installation of [ sensible.vim: Defaults everyone can agree on   ] ..."
  git submodule add -f https://github.com/tpope/vim-sensible.git pack/vendor/start/vim-sensible

  echo "Installation of [ scriptease.vim: A Vim plugin for Vim plugins    ] ..."
  git submodule add -f https://github.com/tpope/vim-scriptease.git pack/vendor/start/vim-scriptease

  echo "Installation of [ Multiple cursors plugin for vim/neovim ] ..."
  git submodule add -f https://github.com/mg979/vim-visual-multi.git pack/vendor/start/vim-visual-multi

  echo "Installation of [ A command-line fuzzy finder   ] ..."
  git submodule add -f https://github.com/junegunn/fzf pack/vendor/start/fzf
  echo "Installation of [ fzf heart vim  ] ..."
  git submodule add -f https://github.com/junegunn/fzf.vim pack/vendor/start/fzf.vim

  echo "Installation of [ A Vim plugin which shows git diff markers in the sign column and stages/previews/undoes hunks and partial hunks. ] ..."
  git submodule add -f https://github.com/airblade/vim-gitgutter.git pack/vendor/start/vim-gitgutter

  echo "Installation of [  emmet for vim: http://emmet.io/ ] ..."
  git submodule add -f https://github.com/mattn/emmet-vim.git pack/vendor/start/emmnet-vim

  echo "Installation of [  Managing project settings for Vim  ] ..."
  git submodule add -f https://github.com/tbknl/vimproject.git pack/vendor/start/vimproject

  echo "Installation of [  Vim configuration for Rust. ] ..."
  git submodule add -f https://github.com/rust-lang/rust.vim pack/vendor/start/rust

  echo "Installation of [ Markdown for Vim: a complete environment to create Markdown files with a syntax highlight that doesn't suck!  ] ..."
  git submodule add -f https://github.com/gabrielelana/vim-markdown.git pack/vendor/start/vim-markdown

  echo "Installation of [ The missing UI extensions for Vim 8.2 (and NeoVim 0.4) !! sunglasses  ] ..."
  git submodule add -f https://github.com/skywind3000/vim-quickui.git pack/vendor/start/vim-quickui

  echo "Installation of [ Vim plugin for the Perl module / CLI script 'ack' ] ..."
  git submodule add -f https://github.com/mileszs/ack.vim.git pack/vendor/start/ack

  echo "Installation of [ vim-snipmate default snippets (Previously snipmate-snippets) ] ..."
  git submodule add -f https://github.com/tomtom/tlib_vim.git pack/vendor/start/tlib_vim
  git submodule add -f https://github.com/MarcWeber/vim-addon-mw-utils.git pack/vendor/start/vim-addon-mw-utils
  git submodule add -f https://github.com/garbas/vim-snipmate.git pack/vendor/start/vim-snipmate
  git submodule add -f https://github.com/honza/vim-snippets.git pack/vendor/start/vim-snippets
}

#echo "Installation of [ Nodejs extension host for vim & neovim, load extensions like VSCode and host language servers. ] ..."
#git submodule add -f --branch release https://github.com/neoclide/coc.nvim.git pack/vendor/start/coc-nvim

#echo "Installation of [Vim plugin for the Perl module / CLI script 'ack']"
#git submodule add -f https://github.com/mileszs/ack.vim.git pack/vendor/start/ack

#echo "Installation of [ lean & mean status/tabline for vim that's light as air  ] ..."
#git submodule add -f https://github.com/vim-airline/vim-airline.git pack/vendor/start/vim-airline
#git submodule add -f https://github.com/vim-airline/vim-airline-themes.git pack/vendor/start/vim-airline-themes

#echo "Installation of [ types "use" statements for you ] ..."
#git submodule add -f https://github.com/arnaud-lb/vim-php-namespace.git pack/vendor/start/vim-php-namespace

# echo "Installation of [ A Vim plugin for Prettier ] ..."
# git submodule add -f https://github.com/prettier/vim-prettier.git pack/vendor/start/vim-prettier
# cd ${CLONE_DIRECTORY}/vim-prettier

# yarn install --frozen-lockfile --production
cd ${VIM_DIRECTORY}

# echo "Installation of [ vim-snipmate default snippets (Previously snipmate-snippets) ] ..."
# # git submodule add -f https://github.com/tomtom/tlib_vim.git --depth=1  vendor/tlib_vim
# # git submodule add -f https://github.com/MarcWeber/vim-addon-mw-utils.git --depth=1  vendor/vim-addon-mw-utils
# # git submodule add -f https://github.com/garbas/vim-snipmate.git --depth=1  vendor/vim-snipmate
# # git submodule add -f https://github.com/honza/vim-snippets.git --depth=1  vendor/vim-snippets

# echo "ultisnips is based on python( I like minimal configuration ) "
# git submodule add -f https://github.com/SirVer/ultisnips vendor/ultisnips

# echo "Installation of [A filetype plugin for VIM to help edit XML files ] ..."
# # git submodule add -f https://github.com/sukima/xmledit vendor/xmledit

# Unwanted / Disabled modules
# echo "Installation of [Automatically opens popup menu for completions ] ..."
# git submodule add -f https://github.com/vim-scripts/AutoComplPop vendor/AutoComplPop

# echo "Installation of [ Perform all your vim insert mode completions with Tab ] ..."
# git submodule add -f https://github.com/ervandew/supertab vendor/supertab

# echo "Installation of [ Go development plugin for Vim ] ..."
# git submodule add -f https://github.com/fatih/vim-go.git --depth=1  vendor/vim-go

git ls-files --stage | grep 160000
git submodule foreach --recursive git clean -xfd
git submodule foreach --recursive git reset --hard
git submodule update --init --recursive --jobs 4 --remote --rebase

bin/composer self-update
bin/composer install --prefer-dist --no-scripts --no-progress --no-interaction --no-dev
${SUDO} npm i -g npm@latest intelephense@latest livereloadx yarn
yarn set version latest

# update coc-nvim plugines
#echo "Wait for 2 minutes, coc-nvim plugines is started updating"
#vim -c 'CocUpdateSync|q'
#echo "Add intelephense license here"
#node -e "console.log(os.homedir() + '/intelephense/licence.txt')"

rm -rf $HOME/.vim/composer.phar $HOME/.vim/vendor $HOME/.vim/composer.lock
composer update
./vendor/bin/grumphp git:init
#./vendor/bin/grumphp
./vendor/bin/grumphp git:deinit

echo "Submodule installation recursive dependence .....................[DONE]."

exit 0
