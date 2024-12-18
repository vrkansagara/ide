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

    call CommentaryRemove()
endfunction

" This function is dynamically called by hitting  enter for filetype
function! Runconf()
    let fileName = expand('%:t') " file name only (with extension)
    let fileNameW = expand('%:p:r') "Absolute file name only (without extension)
    let filePath = expand('%:p') " Absolute to filepath
    let directoryPath = expand('%:p:h') " Absolute to directory

    " Write current file
    execute "silent! w!"
endfunction

" nnoremap <silent> <C-S-F2> :call CommentaryRemove() <cr>
function! CommentaryRemove()
    let fileType = &filetype
    " delete all commentd lines for config file
    " execute "silent! g/^[^#]*#/d"
    " The first ^ will anchor the match to the start of the line, [^#] will match any character except a # (the ^ means to match any character except those given), and the * repeats this 0 or more times.
    execute "silent! g/^*#/d"

    "Remove all line break
    execute "silent! g/^#/d"
endfunction