
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara " 
" Note		 :- 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"  The information in Section Z looks like this:
"  10% ☰ 10/100 ln : 20
"  This means:
"  10%     - 10 percent down the top of the file
"  ☰ 10    - current line 10
"  /100 ln - of 100 lines
"  : 20    - current column 20

let g:airline_disable_statusline=0

" " First line ensures we can have full spectrum of colors
" if has('gui_running') || &term =='linux' || &t_Co < 256
" 	let g:airline_solarized_bg='dark'
" else
" 	let g:airline_solarized_bg='light'
" endif

let g:airline#extensions#tagbar#enabled=1
let g:airline#extensions#tagbar#flags= 'f'
let g:airline#extensions#tabline#enabled=1
let g:airline_powerline_fonts=1
let g:airline_detect_spell=0

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

