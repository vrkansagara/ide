"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :- Julia Related stuff
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" julia parser check (CTRL + l)
" autocmd FileType julia noremap <C-l> :w%!<cr>!julia -l %<CR>
autocmd FileType julia noremap <Leader>l :w!<CR>:!julia -l %<CR>

" .inc, phpt, phtml, phps files as PHP
autocmd BufNewFile,BufRead *.julia set ft=julia

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5julia()
    " Call F2 which is trim whitespace for all file type
    exe "normal \<F2>"

    execute "retab"

    " Clear messages for better visibility (for vim)
    exec "messages clear"

    " reindent whole file without losing current " position
    execute "silent! JuliaFormatterFormat"
    execute "normal gg=G``"
endfunction

    " This function is dynamically called by hiting enter for filetype
function! Runjulia()
    let fileName = expand('%:t') " file name only (with extention)
    let fileNameW = expand('%:p:r') "Absolute file name only (without extention)
    let filePath = expand('%:p') " Absolute to filepath
    let directoryPath = expand('%:p:h') " Absolute to directory

    " Write current file
    execute "silent! retab"
    execute "silent! w!"

    " Clear terminal color, clean screen, run object
    execute "silent! !echo -e '\033[0m' && clear"

    " run php file using unix less to pip the output
    execute "!julia " . filePath

    endfunction

