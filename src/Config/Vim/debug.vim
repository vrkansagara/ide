
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
" Note		 :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" :scriptnames            : list all plugins, _vimrcs loaded (super)
" :verbose set history?   : reveals value of history and where set
" :function               : list functions
" :func SearchCompl       : List particular function

" :scriptnames  " Show all loded script for the vim instanc:
"
" verbose imap <tab>

" Slow Start
" Typing :help slow-start shows Vim's built-in guidance on startup performance

"It’s also possible to load Vim without ~/.vimrc. This can be useful for
"determining if the problem is caused by your settings or the way Vim was built
"on your system:
"vim -u NONE --startuptime vim-NONE.log

"Profiling
" Vim includes profiling tools that can be essential when debugging scripts.
" This can be used from the command-line to measure how long each function takes
" when Vim is started:

" vim -c 'profile start vim.log' -c 'profile func *' -c 'q'
