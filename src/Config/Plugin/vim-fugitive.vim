" ==============================================================================
" File        : vim-fugitive.vim
" Maintainer  : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
" Version     : 2.0.0
" Description : vim-fugitive Git integration and diff key bindings
" ==============================================================================

" :help fugitive
" Url        :-  https://github.com/tpope/vim-fugitive/blob/master/doc/fugitive.txt
" Url(1)     :-  http://vimcasts.org/episodes/fugitive-vim-resolving-merge-conflicts-with-vimdiff/

if exists('g:loaded_vim_fugitive_config')
    finish
endif
let g:loaded_vim_fugitive_config = v:true

" Useful additions to make this process whole:

"     Jumping to the next git hunk (or conflict to fix) can be done with [c to
" backward or ]c to search forward "     When you are satisfied with your
" workspace (usually when all conflicts are resolved) it's time to leave just this
" pane open; we can do that with <C-w>o which tells VIM's window manager to leave
" the current pane only.

" command     effect
" [c          jump to previous hunk
" ]c          jump to next hunk
" dp          shorthand for `:diffput`
" :only       close all windows apart from the current one
" :Gwrite[!]  write the current file to the index
" Fugitive Conflict Resolution

nnoremap <leader>gd :Gvdiff<CR>
nnoremap gdh :diffget //2<CR>
nnoremap gdl :diffget //3<CR>
