"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if !has("terminal")
    echomsg "There is no terminal available"
    finish
endif

nnoremap <leader>tt :terminal ++rows=25<cr>
nnoremap <leader>to :terminal ++rows=5<cr>
inoremap <F12> :call Terminal()<cr>
nnoremap <F12> :call Terminal()<cr>

function Terminal()
    function! OnTermExit(job, message)
        close
        " TODO: add some code to confirm that current window is a popup.
        " TODO: prevent close other window by accident.
    endfunction

    let w = 80
    let h = 24
    let opts = {'hidden': 1, 'term_rows':h, 'term_cols':w}
    let opts.term_kill = 'term'
    let opts.norestore = 1
    let bid = term_start(['zsh'], opts)
    let opts.exit_cb = 'OnTermExit'

    let opts = {'maxwidth':w, 'maxheight':h, 'minwidth':w, 'minheight':h}
    let opts.wrap = 0
    let opts.mapping = 0
    let opts.title = 'VRKANSAGARA-Terminal'
    let opts.close = 'button'
    let opts.border = [2,2,2,2,2,2,2,2,2]
    let opts.drag = 1
    let opts.resize = 1
    let winid = popup_create(bid, opts)
endfunction

" function! ToggleProjectVK()
"   call ToggleTerm('bash')
" endfunction

" function! ToggleTerm(cmd)
"   if empty(bufname(a:cmd))
"       call CreateCenteredFloatingWindow()
"       call termopen(a:cmd, { 'on_exit': function('OnTermExit') })
"   else
"       bwipeout!
"   endif
" endfunction
