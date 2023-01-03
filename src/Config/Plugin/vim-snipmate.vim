
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:snipMate = get(g:, 'snipMate', {}) " Allow for vimrc re-sourcing
let g:snipMate.scope_aliases = {}
let g:snipMate.scope_aliases['ruby'] = 'ruby,rails'
let g:snipMate.scope_aliases['php'] = 'php,phtml,html'
let g:snipMate.scope_aliases['vim'] = 'vim'


let g:snipMate = { 'snippet_version' : 1 }

"Custom snippets directory
" https://github.com/garbas/vim-snipmate/blob/master/plugin/snipMate.vim#L99
" List of paths where snippets/ dirs are located
let g:snipMate.snippet_dirs = ['~/.vim/src/']

" snipMate options
" echo g:snipMate
let g:snips_author = "Vallabh Kansagara"
" imap <C-T> <Plug>snipMateNextOrTrigger
" smap <C-T> <Plug>snipMateNextOrTrigger
