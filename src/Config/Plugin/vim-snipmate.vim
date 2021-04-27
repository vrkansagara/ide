let g:snipMate = get(g:, 'snipMate', {}) " Allow for vimrc re-sourcing
let g:snipMate.scope_aliases = {}
let g:snipMate.scope_aliases['ruby'] = 'ruby,rails'
let g:snipMate.scope_aliases['php'] = 'php,phtml,html'
let g:snipMate = { 'snippet_version' : 1 }


" snipMate options
" echo g:snipMate
let g:snips_author = "Vallabh Kansagara"
imap <C-T> <Plug>snipMateNextOrTrigger
smap <C-T> <Plug>snipMateNextOrTrigger
