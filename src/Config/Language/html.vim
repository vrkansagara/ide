
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

	" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5html()
	" Call F2 which is trim whitespace for all file type
	exe "normal \<F2>"

	" Indent whole file ( VIM Style is no good so moving to prettier)
	" exe "normal gg=G``"
	execute "PrettierAsync"
	endfunction

	" This function is dynamically called by hitting  enter for filetype
function! Runhtml()
	let fileName = expand('%:t') " file name only (with extension)
	let fileNameW = expand('%:p:r') "Absolute file name only (without extension)
	let filePath = expand('%:p') " Absolute to filepath
	let directoryPath = expand('%:p:h') " Absolute to directory

	" Write current file
	execute "silent! w!"

	" Clear terminal color, clean screen, run object
	execute "silent! echo -e '\033[0m' && clear"
	endfunction

