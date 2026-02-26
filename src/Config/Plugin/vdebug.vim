" ==============================================================================
" File        : vdebug.vim
" Maintainer  : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
" Version     : 2.0.0
" Description : Vdebug (Xdebug) debugger configuration
" ==============================================================================

if exists('g:loaded_vdebug_config')
    finish
endif
let g:loaded_vdebug_config = v:true

let g:vdebug_options = {
    \ 'ide_key'       : 'vim-xdebug',
    \ 'break_on_open' : 0,
    \ 'server'        : '127.0.0.1',
    \ 'port'          : '9000',
    \ }
