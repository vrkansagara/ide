
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note		 :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ====  ack.vim quick help ===============
" *?:*  a quick summary of these keys, repeat to close
" *o:*  to open (same as Enter)
" *O:*  to open and close the quickfix window
" *go:*  to preview file, open but maintain focus on ack.vim results
" *t:*  to open in new tab
" *T:*  to open in new tab without moving to it
" *h:*  to open in horizontal split
" *H:*  to open in horizontal split, keeping focus on the results
" *v:*  to open in vertical split
" *gv:*  to open in vertical split, keeping focus on the results
" *q:*  to close the quickfix window
" ========================================

" ACK support
set grepprg=ack-grep\ -a
map <leader>g :Ack!<space>

" Use ag if available for quicker searches
if executable('ag')
	" Use Ag over Grep
	set grepprg=ag\ --nogroup\ --nocolor

	" let g:ackprg = 'ag --vimgrep'
	let g:ackprg = 'ag --nogroup --nocolor --column '
	"
	" Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
	let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

endif

" Quick command to find todo and debug into codebase
command Todo Ack! 'TODO|FIXME|CHANGED|BUG|HACK'
command Debug Ack! 'NOTE|IDEA|INFO|WARNING|CRITICAL'

if has("autocmd")
	" Highlight TODO, FIXME, NOTE, etc.
	if v:version > 701
		autocmd Syntax * call matchadd('Todo', '\W\zs\(TODO\|FIXME\|CHANGED\|BUG\|HACK\)')
		autocmd Syntax * call matchadd('Debug', '\W\zs\(NOTE\|IDEA\|INFO\|WARNING\|CRITICAL\)')
	endif
endif
