
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note		 :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" .sh files as Shell script
autocmd BufNewFile,BufRead *.sh set ft=sh

" Disable automate comment insertation
:autocmd FileType *.sh setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" nnoremap <F9> :!chmod +x % <CR>:!%:p<CR>
" nnoremap <leader>r :!%:p

" run file with PHP CLI (CTRL-m)
" ":autocmd FileType sh noremap <C-m> :w!<CR>:!chmod +x %<CR>:! clear && sh %<CR>
:autocmd FileType sh noremap <C-m> :w!<CR>:! clear<CR>:!chmod +x %<CR>:! %:p<CR>

