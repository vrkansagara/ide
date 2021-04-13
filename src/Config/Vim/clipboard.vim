
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara " 
" Note		 :- 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Yank text to the clipboard easier (y = yank|copy , d = delete|cut, p = paste) (Register
" *=window, + = linux) - In normal mode, one can use p to paste after the cursor, or P to paste before the cursor.
if has('clipboard')
	if has("win32")
		"Windows options here
		noremap <leader>y "*y
		noremap <leader>yy "*Y
		noremap <leader>p "*p
	else
		if has("unix")
			let s:uname = system("uname")
			if s:uname == "Darwin\n"
				"Mac options here
			elseif s:uname == "Linux\n"
				" Linux stuff
				noremap <leader>y "+y
				noremap <leader>yy "+Y
				noremap <leader>p "+p
			endif
		endif
	endif
else
	echomsg "Clipboard functionality is not present with current VIM"
endif


