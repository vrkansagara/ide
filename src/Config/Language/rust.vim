"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" .sh files as Shell script
autocmd BufNewFile,BufRead *.rust set ft=rust

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5rust()
    " Call F2 which is trim whitespace for all file type
    exe "normal \<F2>"
    " Indent whole file
    exe "normal gg=G``"
endfunction

" This function is dynamically called by hitting  enter for filetype
function! Runrust()
    let fileName = expand('%:t') " file name only (with extension)
    let fileNameW = expand('%:p:r') "Absolute file name only (without extension)
    let filePath = expand('%:p') " Absolute to filepath
    let directoryPath = expand('%:p:h') " Absolute to directory

    execute "silent! mkdir -p /tmp". fileNameW
    let outputpath =  "/tmp" . fileNameW . ".o"

    " This warning is enabled -Wall
    " -Wall = Show all possible warning, -g = Include debug information
    " Linux kernal comiplation using this commit standard
    " https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=51b97e354ba9fce1890cf38ecc754aa49677fc89
    " run file with gnu compiler
    let gcc_options = " -g -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer -std=gnu89 "
    let output_options = " -o ". outputpath

    " Write current file
    execute "silent! w!"

    " compile current file with gcc options
    " execute "silent !rustc " . gcc_options . filePath . output_options
    execute "silent !rustc " . filePath

    " Clear terminal color, clean screen, run object
    " execute "! echo -e '\033[0m' && clear && " . fileNameW
    execute "! echo -e '\033[0m' && " . fileNameW
endfunction
