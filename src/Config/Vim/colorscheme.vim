"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :- Do not rename this file                                 "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" First line ensures we can have full spectrum of colors
" if has('gui_running') || &term =='linux' || &t_Co < 256
"   set bg=dark
"   set background=dark
"   colorscheme atom-dark-256
" else
"   set t_Co=256
"   set background=light
"   colorscheme PaperColor
" endif

" https://github.com/vim/vim/issues/993#issuecomment-255651605
" set Vim-specific sequences for RGB colors
if exists('+termguicolors')
	" let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
	" let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    " set termguicolors
endif

" Set default color scheme
if exists("g:syntax_on")
	syntax off
endif
set t_Co=256
set bg=dark
set background=dark
colorscheme atom-dark-256
let g:airline_theme='base16_google'
" Let syntax enable after colour scheme apply for better highlight
syntax on

" set runtimepath=$HOME/.vim/src,usr/share/vim/
" set term=xterm
" Clear screen set t_te="^[[H^[2J"
" :default one  t_te=^[[?1049l^[[23;0;0t
" set t_te="^[[?1049l^[[23;0;0t"
" I wanted to use F5 key for filetype so comment it
" map <F5> :call ChangeColorScheme()<CR>
function! ChangeColorScheme()
	try
		if (&background == "light")
			syntax off
			let g:airline_theme='base16_google'
			set background=dark
			colorscheme atom-dark-256
			syntax on
		else
			syntax off
			let g:airline_theme='papercolor'
			set background=light
			colorscheme PaperColor
			syntax on
		endif
	catch
		throw exception
	endtry
endfunction
