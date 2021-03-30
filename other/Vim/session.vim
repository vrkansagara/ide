"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" About:- session related configuration
" Maintainer:- Vallabh Kansagara — @vrkansagara
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Remember settings between sessions
" set viminfo='400,f1,"500,h,/100,:100,<500

" Ref:- https://stackoverflow.com/a/31978241/2627408
function! MakeSession()
	let b:sessiondir = $HOME . "/.vim/data/sessions" . getcwd()
	if (filewritable(b:sessiondir) != 2)
		exe 'silent !mkdir -p ' b:sessiondir
		redraw!
	endif
	let b:filename = b:sessiondir . '/session.vim'
	exe "mksession! " . b:filename
endfunction

function! LoadSession()
	let b:sessiondir = $HOME . "/.vim/data/sessions" . getcwd()
	let b:sessionfile = b:sessiondir . "/session.vim"
	if (filereadable(b:sessionfile))
		exe 'source ' b:sessionfile
	else
		echo "No session loaded."
	endif
endfunction

" Adding automatons for when entering or leaving Vim
if(argc() == 0)
	" au VimEnter * nested :call LoadSession()
endif

" au VimLeave * :call MakeSession()
