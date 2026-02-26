" ==============================================================================
" File        : 005-fzf.vim
" Maintainer  : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
" Version     : 2.0.0
" Description : fzf fuzzy finder key bindings
" ==============================================================================

if exists('g:loaded_fzf_config')
    finish
endif
let g:loaded_fzf_config = v:true

"Open git file window
nnoremap <C-g> :GFiles<CR>

" Open file window using fzf
nnoremap <C-f> :Files<CR>
