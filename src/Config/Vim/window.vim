
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
" Note		 :- window related configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set splitbelow
set splitright

"Vim Splits - Move Faster and More Naturally
" Map <leader>f to split horizontally, and move to bottom window
nnoremap <leader>hh <C-w>s<C-w>j
nnoremap <leader>vv <C-w>v<C-w>j

nnoremap <leader>wh :new <cr>
nnoremap <leader>wv :vnew <cr>

" Use <ctrl> plus direction key to move around within windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
