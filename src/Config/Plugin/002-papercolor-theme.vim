
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara " 
" Note		 :- Do not rename of file                                   "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

syntax enable

" First line ensures we can have full spectrum of colors
if has('gui_running') || &term =='linux' || &t_Co < 256
	set bg=dark
	set background=dark
	colorscheme default
else
    set t_Co=256
	set background=light
	colorscheme PaperColor
endif
