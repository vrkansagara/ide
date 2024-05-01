"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" .sh files as Shell script
autocmd BufNewFile,BufRead *.sh set ft=sh

" Disable automate comment insertation
autocmd FileType *.sh setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" nnoremap <F9> :!chmod +x % <CR>:!%:p<CR>
" nnoremap <leader>r :!%:p

" run file with PHP CLI (CTRL-m)
" ":autocmd FileType sh noremap <C-m> :w!<CR>:!chmod +x %<CR>:! clear && sh %<CR>
autocmd FileType sh noremap <C-m> :w!<CR>:! clear<CR>:!chmod +x %<CR>:! %:p<CR>

    " This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5sh()
    " Call F2 which is trim whitespace for all file type
    exe "normal \<F2>"
    " Indent whole file
    exe "normal gg=G``"
    endfunction

    " This function is dynamically called by hiting enter for filetype
function! Runsh()
    let fileName = expand('%:t') " file name only (with extention)
    let fileNameW = expand('%:p:r') "Absolute file name only (without extention)
    let filePath = expand('%:p') " Absolute to filepath
    let directoryPath = expand('%:p:h') " Absolute to directory

    " Lets check shell errors
    "execute "shellcheck %"

    " Write current file
    " execute "silent! w!"

    " Clear terminal color, clean screen, run object
    " execute "!clear && sh " . filePath
    execute "!sh " . filePath
    endfunction

