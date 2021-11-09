#!/usr/bin/env bash

# readarray array <<< $( cat "$@" )

CLONE_PATH="$HOME/.vim/pack/vendor/"

## declare an array variable
declare -a array=(
"https://github.com/neoclide/coc.nvim.git"
"https://github.com/tpope/vim-pathogen.git"
)

mkdir -p ${CLONE_PATH} # You can access them using echo "${arr[0]}", "${arr[1]}" also
for element in ${array[@]}
do
	echo "clonning $element"
	cd ${CLONE_PATH}
	git clone -b master --depth=1 $element  .
done
