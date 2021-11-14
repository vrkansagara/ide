
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5json()
    " Call F2 which is trim whitespace for all file type
    exe "normal \<F2>"

    " Indent whole file ( VIM Style is no good so moving to prettier)
    " exe "normal gg=G``"
	execute "PrettierAsync"
endfunction

