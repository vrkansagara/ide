
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" .sh files as Shell script
autocmd BufNewFile,BufRead *.go set ft=go

" Disable automate comment insertation
:autocmd FileType *.go setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" nnoremap <F9> :!chmod +x % <CR>:!%:p<CR>
" nnoremap <leader>r :!%:p

" run file with PHP CLI (CTRL-m)
" ":autocmd FileType sh noremap <C-m> :w!<CR>:!chmod +x %<CR>:! clear && sh %<CR>
:autocmd FileType go noremap <C-m> :w!<CR>:! clear<CR>:!chmod +x %<CR>:! %:p<CR>

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5go()
    " Call F2 which is trim whitespace for all file type
    exe "normal \<F2>"
    " Indent whole file
    exe "normal gg=G``"
endfunction

" This function is dynamically called by hitting  enter for filetype
function! Rungo()
    let fileName = expand('%:t') " file name only (with extension)
    let fileNameW = expand('%:p:r') "Absolute file name only (without extension)
    let filePath = expand('%:p') " Absolute to filepath
    let directoryPath = expand('%:p:h') " Absolute to directory

    execute "silent! mkdir -p /tmp". fileNameW
    let outputpath =  "/tmp" . fileNameW . ".o"

    let output_options = " -o ". outputpath

    " Write current file
    execute "silent! w!"

    " compile current file with gcc options
    execute "silent! go build " . filePath . output_options


    " Clear terminal color, clean screen, run object
    " execute "silent! echo -e '\033[0m' && clear"
    execute "! echo -e '\033[0m' && clear && " . outputpath
    " exe "!sh " . filePath
endfunction

