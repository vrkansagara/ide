
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note		 :- 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5xml()
    " Call F2 which is trim whitespace for all file type
    exe "normal \<F2>"

    " reindent whole file without losing current " position
    " exe "normal gg=G``"
	execute "PrettierAsync"

endfunction

" This function is dynamically called by hitting  enter for filetype
function! Runxml()
	execute "PrettierAsync"
endfunction
