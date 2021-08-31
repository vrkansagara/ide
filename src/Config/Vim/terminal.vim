
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note		 :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


nnoremap <leader>to :terminal ++rows=5<cr>
" inoremap <F12> :terminal ++rows=5<cr>
" nnoremap <F12> :terminal ++rows=5<cr>

inoremap <F12> :call Terminal()<cr>
nnoremap <F12> :call Terminal()<cr>


function Terminal()
	let w = 120 " 80
	let h = 30 " 24
	let opts = {'hidden': 1, 'term_rows':h, 'term_cols':w}
	let opts.term_kill = 'term'
	let opts.norestore = 1
	let bid = term_start(['zsh'], opts)
	let opts.exit_cb = 'OnTermExit'

	function! OnTermExit(job, message)
		close
		" TODO: add some code to confirm that current window is a popup.
		" TODO: prevent close other window by accident.
	endfunction

	let opts = {'maxwidth':w, 'maxheight':h, 'minwidth':w, 'minheight':h}
	let opts.wrap = 0
	let opts.mapping = 0
	let opts.title = 'VRKANSAGARA-Terminal'
	let opts.close = 'button'
	let opts.border = [1,1,1,1,1,1,1,1,1]
	let opts.drag = 1
	let opts.resize = 0
	let winid = popup_create(bid, opts)
endfunction
