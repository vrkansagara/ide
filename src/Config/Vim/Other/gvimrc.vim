
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has("gui_running")
    set go=agimt
    set guifont=Hack\ 12
    set linespace=10
    set lines=14

    " Power management savings -- turn off blinking cursor
    let &guicursor = &guicursor . ",a:blinkon0"

    " Do not display Toolbar or menus
    :set go-=T
    :set go-=m

    " In gvim, we can safely use the 'fancy' Powerline symbols
    let g:Powerline_symbols="fancy"
    let g:Powerline_cache_file="~/.vim/data/tmp/Powerline-gvim.cache"
endif
