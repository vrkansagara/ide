"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" set nobackup " Disable backupfile
" set noswapfile " Disable swapfile
" set noundofile " Disable undo

set undofile
set undolevels=1000         " How many undos
set undoreload=10000        " number of lines to save for undo

set backup                        " enable backups
"The swap file is updated after typing 200 characters or when you have not typed
"anything for four seconds.
set swapfile                      " enable swaps
set undodir=$HOME/.vim/data/undo     " undo files
set backupdir=$HOME/.vim/data/backup " backups
set directory=$HOME/.vim/data/swap   " swap files

" Make those folders automatically if they don't already exist.
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), "p")
endif
if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), "p")
endif
if !isdirectory(expand(&directory))
    call mkdir(expand(&directory), "p")
endif
