
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5markdown()
    " Call F2 which is trim whitespace for all file type
    " exe "normal \<F2>"
    " Indent whole file
    exe "normal gg=G``"
endfunction


" This function is dynamically called by hitting  enter for filetype
function! Runmarkdown()
    " Write current file
    execute "silent! w!"

    endfunction
