
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note		 :-
	"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! Cap_Status()
	let St = systemlist('xset -q | grep "Caps Lock" | awk ''{print $4}''')[0]
	return St
	endfunction

function! Capsoff()
	if Cap_Status() == "on"
	call system("xdotool key Caps_Lock")
	redraw
	highlight Cursor guifg=white guibg=black
	endif
	endfunction

function! Caps_Toggle()
	call system("xdotool key Caps_Lock")
	redraw
	if Cap_Status() == "on"
	highlight Cursor guifg=white guibg=green
	else
	highlight Cursor guifg=white guibg=black
	endif

	endfunction
autocmd InsertLeave * call Capsoff()
