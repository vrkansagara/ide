
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note		 :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" execute external command and past standarad output in insert mode ( CTRL+R a )
" @a is the register name
let @a = system("ls -lhtr")
let @p = system('uname -a && lsb_release -a')
