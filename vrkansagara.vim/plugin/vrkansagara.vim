" vrkansagara.vim - My Own configuration
" Maintainer:   Vallabh Kansagara <https://vrkansagara.in/>
" Version:      0.1

if exists('g:loaded_vrkansagara')
    finish
endif
let g:loaded_vrkansagara = 1

let s:bad_git_dir = '/$\|^vrkansagara:'
echo "Do one thing at a time and do it well - Vallabh Kansagara (VRKANSAGARA)."

if &filetype == ""
    " echoerr "There is no file type"
endif