"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" About:- number related configuration
" Maintainer:- vallabhdas kansagara — @vrkansagara
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" This setting can be useful for determining how many lines of text you want to
" yank. It will display the line number column, but lines will be the distance

" from the current line.
" :set number relativenumber
" Line number must be relative and can be change based on event of mode
set number relativenumber

augroup numbertoggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
	autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END
