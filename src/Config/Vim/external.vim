
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note		 :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" execute external command and past standard output in insert mode ( CTRL+R a )
" @a is the register name
let @a = system("ls -lhtra") " CTRL+R --> a
let @p = system('uname -a && lsb_release -a') " CTRL+R --> p
let @t = system('tree -L 2 .') " CTRL+R --> t
