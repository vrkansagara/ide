
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara " 
" Note		 :- Do not rename this file                                   "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

syntax enable

" First line ensures we can have full spectrum of colors
if has('gui_running') || &term =='linux' || &t_Co < 256
	set bg=dark
	set background=dark
	colorscheme atom-dark-256
else
	set t_Co=256
	set background=light
	colorscheme PaperColor
endif

nnoremap <F5> :call ChangeColorScheme()<CR>
function! ChangeColorScheme()
	try
		if (&background == "light")
			let g:airline_theme='base16_google'
			set background=dark
			colorscheme atom-dark-256
		else
			let g:airline_theme='papercolor'
			set background=light
			colorscheme PaperColor
		endif
	catch
		throw exception
	endtry
endfunction
