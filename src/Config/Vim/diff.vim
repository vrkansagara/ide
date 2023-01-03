
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" ]c               - advance to the next block with differences
" [c               - reverse search for the previous block with differences
" do (diff obtain) - bring changes from the other file to the current file
" dp (diff put)    - send changes from the current file to the other file
" zo               - unfold/unhide text
" zc               - refold/rehide text
" zr               - unfold both files completely
" zm               - fold both files completely
" :diffg RE  " get from REMOTE
" :diffg BA  " get from BASE
" :diffg LO  " get from LOCAL

if ! &diff
    finish
endif

" diff mode
set diffopt+=iwhite
set diffexpr=""

