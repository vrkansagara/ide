
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" commentary.vim

" Comment stuff out. Use gcc to comment out a line (takes a count), gc to
" comment out the target of a motion (for example, gcap to comment out a
" paragraph), gc in visual mode to comment out the selection, and gc in operator
" pending mode to target a comment. You can also use it as a command, either
" with a range like :7,17Commentary, or as part of a :global invocation like
" with :g/TODO/Commentary. That's it.

" Oh, and it uncomment, too. The above maps actually toggle, and gcgc uncomment
" a set of adjacent commented lines.

map <C-_> :Commentary<CR>j
map <S-_> :Commentary<CR>k

" Comment which having \ or //
autocmd FileType vim setlocal commentstring=\"\ %s
autocmd FileType php setlocal commentstring=\/\/\%s
autocmd FileType c setlocal commentstring=\/\/\%s
autocmd FileType h setlocal commentstring=\/\/\%s
autocmd FileType cpp setlocal commentstring=\/\/\%s
autocmd FileType cspel setlocal commentstring=\/\/\%s

" Comment which having #
autocmd FileType crontab setlocal commentstring=#\ %s
autocmd FileType apache setlocal commentstring=#\ %s
autocmd FileType zsh setlocal commentstring=#\ %s
autocmd FileType dockerfile setlocal commentstring=#\ %s
autocmd FileType gitconfig setlocal commentstring=#\ %s
autocmd FileType sh setlocal commentstring=#\ %s
autocmd FileType conf setlocal commentstring=#\ %s
