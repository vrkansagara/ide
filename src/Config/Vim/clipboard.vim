"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Vim offers the + and * registers to reference the system clipboard (:help quoteplus and :help quotestar). Note that on some systems, + and * are the same, while on others they are different. Generally on Linux, + and * are different


" + corresponds to the desktop clipboard (XA_SECONDARY) that is accessed using CTRL-C, CTRL-X, and CTRL-V
" * corresponds to the X11 primary selection (XA_PRIMARY), which stores the mouse selection and is pasted using the middle mouse button in most applications

" gg"+yG – copy the entire buffer into + (normal mode)
"*dd – cut the current line into * (normal mode)
"+p – paste from + after the cursor (works in both normal and visual modes)
" :%y * – copy the entire buffer into * (this one is an ex command)

" Fortunately, Vim remembers previous deletes/yanks in the numbered registers.
" You can enter the command :reg to list all the registers.
" If the text you want is in register 2, enter "2p to paste it after the cursor,
" or "2P to paste it before the cursor.

" Yank text to the clipboard easier (y = yank|copy , d = delete|cut, p = paste)
" (Register *=window, + = linux) - In normal mode, one can use p to paste after
" the cursor, or P to paste before the cursor.

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
