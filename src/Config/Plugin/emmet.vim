" ==============================================================================
" File        : emmet.vim
" Maintainer  : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
" Version     : 2.0.0
" Description : Emmet plugin configuration for HTML/CSS/PHP expansion
" ==============================================================================

if exists('g:loaded_emmet_config')
    finish
endif
let g:loaded_emmet_config = v:true

let g:user_emmet_leader_key='<C-Y>'

let g:user_emmet_install_global = 0

augroup emmet_install
    autocmd!
    autocmd FileType html,css,php EmmetInstall
augroup END
