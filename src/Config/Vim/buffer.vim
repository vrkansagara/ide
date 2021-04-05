" :bd          - deletes the current buffer, error if there are unwritten changes
" :bd!         - deletes the current buffer, no error if unwritten changes
" :bufdo bd    - deletes all buffers, stops at first error (unwritten changes)
" :bufdo! bd   - deletes all buffers except those with unwritten changes
" :bufdo! bd!  - deletes all buffers, no error on any unwritten changes

" :bw          - completely deletes the current buffer, error if there are unwritten changes
" :bw!         - completely deletes the current buffer, no error if unwritten changes
" :bufdo bw    - completely deletes all buffers, stops at first error (unwritten changes)
" :bufdo! bw   - completely deletes all buffers except those with unwritten changes
" :bufdo! bw!  - completely deletes all buffers, no error on any unwritten changes

" :set confirm - confirm changes (Yes, No, Cancel) instead of error


" This is the place holder file for the reference.
" For more detail check main.vim for quite/close
