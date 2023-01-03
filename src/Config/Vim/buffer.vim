"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
" Note		 :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" :bd          - deletes the current buffer, error if there are unwritten
" changes
" :bd!         - deletes the current buffer, no error if unwritten changes
" :bufdo bd    - deletes all buffers, stops at first error (unwritten changes)
" :bufdo! bd   - deletes all buffers except those with unwritten changes
" :bufdo! bd!  - deletes all buffers, no error on any unwritten changes

" :bw          - completely deletes the current buffer, error if there are
" unwritten changes
" :bw!         - completely deletes the current buffer, no error if unwritten
" changes
" :bufdo bw    - completely deletes all buffers, stops at first error (unwritten
" changes)
" :bufdo! bw   - completely deletes all buffers except those with unwritten
" changes
" :bufdo! bw!  - completely deletes all buffers, no error on any unwritten
" changes

" :set confirm - confirm changes (Yes, No, Cancel) instead of error


" This is the place holder file for the reference.
" For more detail check main.vim for quite/close
"
"Vim can open multiple files, each in its own buffer. Here is how to save all
"changes and continue working, or save all changes and exit Vim. It is also
"possible to quit all (discard changes).

" :wa   write all changed files (save all changes), and keep working
" :xa   exit all (save all changes and close Vim)
" :wqa  same as :xa
" :qa   quit all (close Vim, but not if there are unsaved changes)
" :qa!  quit all (close Vim without saving—discard any changes)
" The :wa and :xa commands only write a file when its buffer has been changed.
" By contrast, the :w command always writes the current buffer to its file (use
" :update to save the current buffer only if it has been changed).

" Warning: If you enter :qa!, Vim will discard all changes without asking "are
" you sure?".

" h special-buffers
command! Scratch new | setlocal buftype=nofile bufhidden=hide noswapfile

" "Hidden" buffers -- i.e., don't require saving before editing another file.
" Calling quit will prompt you to save unsaved buffers anyways.
set hidden		" Hide buffers when they are abandoned