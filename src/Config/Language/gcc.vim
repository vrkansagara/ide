"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :- GCC compiler related configuration.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup filetypedetect
    au! BufRead,BufNewFile *.c,*.cpp,*.h    setfiletype c
augroup END

" Ensure tabs don't get converted to spaces in Makefiles.
autocmd FileType make setlocal noexpandtab

" au BufEnter *.c compiler gcc
" au BufEnter *.cpp compiler gcc
" au BufEnter *.h compiler gcc

" Linux kernal comiplation using this commit standard
" https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=51b97e354ba9fce1890cf38ecc754aa49677fc89
" run file with gnu compiler

" This warning is enabled -Wall
" autocmd FileType c noremap <C-M> :w!<CR>:! mkdir -p /tmp/%<CR>:!/usr/bin/gcc %
" -Wall = Show all possible warning, -g = Include debug information
" autocmd FileType c noremap <C-M> :w!<CR>:! mkdir -p /tmp/%<CR>:!/usr/bin/gcc
" \ -g
" \ -Wall
" \ -Wmissing-prototypes
" \ -Wstrict-prototypes
" \ -O2
" \ -fomit-frame-pointer
" \ -std=gnu89
" \ -o /tmp/%.out % && clear && /tmp/%.out<CR>

function Libsort()
    normal mfgg}
    let lineNumber = line('.') - 1
    execute '1,' . lineNumber . '!sort -u'
    normal 'f
endfunction

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5c()
    " Call F2 which is trim whitespace for all file type
    exe "normal \<F2>"

    " Converting DOS to UNIX
    execute "silent! %s/^ m //g"

    "Sort include library
    execute "silent! call Libsort()"

    " Indent whole file
    exe "normal gg=G``"
endfunction

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5make()
    " Call F2 which is trim whitespace for all file type
    exe "normal \<F2>"

    " Converting DOS to UNIX
    execute "silent! %s/^ m //g"

    " Indent whole file
    exe "normal gg=G``"

endfunction

" This function is dynamically called by hiting enter for filetype
function! Runc()
    let fileName = expand('%:t') " file name only (with extention)
    let fileNameW = expand('%:p:r') "Absolute file name only (without extention)
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
    execute "silent !gcc " . gcc_options . filePath . output_options

    " Clear terminal color, clean screen, run object
    execute "! echo -e '\033[0m' && clear && " . outputpath
endfunction

" This function is dynamically called by hiting enter for filetype
function! Runmake()
    let fileName = expand('%:t') " file name only (with extention)
    let fileNameW = expand('%:p:r') "Absolute file name only (without extention)
    let filePath = expand('%:p') " Absolute to filepath
    let directoryPath = expand('%:p:h') " Absolute to directory

    " Write current file
    execute "silent! w!"

    " Clear terminal color, clean screen, run object
    execute "! echo -e '\033[0m' && clear && ake clean "

endfunction