"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File name :- 002-papercolor-them.vim
" About:- Color scheme for the editor.
" Maintainer:- Vallabh Kansagara — @vrkansagara
" Note:- Do not rename of file , as It used for priority include name(002)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
