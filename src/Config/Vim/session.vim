"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Uncomment the following to have Vim jump to the last position when
" reopening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Remember settings between sessions
set viminfo='400,f1,"500,h,/100,:100,<500

" Why don't my plugins load when I use Vim sessions?
set sessionoptions-=options

" Why terminal window load when I use Vim built in terminal ?
set sessionoptions-=terminal

au VimLeave * :call MakeSession()
" Adding automatons for when entering or leaving Vim
if(argc() == 0)
    " issue :- Error detected while processing VimEnter Autocommands for "*"..function LoadSession[4]..scrip
    " E475: Invalid argument: 2: tabnext 2
    " au VimEnter * nested :call LoadSession()
endif

" Ref:- https://stackoverflow.com/a/31978241/2627408
function! MakeSession()
    let b:sessiondir = $HOME . "/.vim/data/sessions" . getcwd()
    if (filewritable(b:sessiondir) != 2)
        exe 'silent !mkdir -p ' b:sessiondir
        redraw!
    endif
    let b:filename = b:sessiondir . '/session.vim'
    exe "mksession! " . b:filename
endfunction

function! LoadSession()
    let b:sessiondir = $HOME . "/.vim/data/sessions" . getcwd()
    let b:sessionfile = b:sessiondir . "/session.vim"
    if (filereadable(b:sessionfile))
        exe 'source ' b:sessionfile
    else
        echo "No session loaded."
    endif
endfunction

