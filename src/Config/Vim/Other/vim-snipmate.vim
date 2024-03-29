let g:snips_author = "vallabhdas kansagara"

" snipMate options
let g:snipMate = {}
let g:snipMate = { 'snippet_version' : 1 }
let g:snipMate.scope_aliases = {}

let &runtimepath.=','.'~/.vim/src/'

imap <C-T> <Plug>snipMateNextOrTrigger
smap <C-T> <Plug>snipMateNextOrTrigger
