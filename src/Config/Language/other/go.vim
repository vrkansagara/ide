
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" PHP parser check (CTRL + l)
" autocmd FileType go noremap <C-l> :w!<CR>:! echo -e "\033[0m" /usr/bin/clear && go -l %<CR>

" run file with PHP CLI (CTRL-m)
" autocmd FileType go noremap <C-m> :w!<CR>:!go %<CR>
