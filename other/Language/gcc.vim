"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" About:- GCC compiler related configuration
" Maintainer:- Vallabh Kansagara — @vrkansagara
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

au BufEnter *.c compiler gcc
au BufEnter *.cpp compiler gcc
au BufEnter *.h compiler gcc

" run file with gnu compiler
:autocmd FileType c noremap <C-M> :w!<CR>:! mkdir -p /tmp/%<CR>:!/usr/bin/gcc % -std=gnu89 -o /tmp/%.out && /tmp/%.out<CR>
