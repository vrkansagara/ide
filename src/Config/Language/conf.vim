"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5conf()

    " Call F2 which is trim whitespace for all file type
    exe "normal \<F2>"

    " Indent whole file
    exe "normal gg=G``"

endfunction

" This function is dynamically called by hitting  enter for filetype
function! Runconf()
    let fileName = expand('%:t') " file name only (with extension)
    let fileNameW = expand('%:p:r') "Absolute file name only (without extension)
    let filePath = expand('%:p') " Absolute to filepath
    let directoryPath = expand('%:p:h') " Absolute to directory

endfunction

