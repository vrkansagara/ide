"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5json()
    " Call F2 which is trim whitespace for all file type
    exe "normal \<F2>"

    " Indent whole file with jq way
    exe "%!jq ."

    " Indent whole file ( VIM Style is no good so moving to prettier)
    " exe "normal gg=G``"
endfunction


function! Runjson()
    :call RefreshF5json()
endfunction
