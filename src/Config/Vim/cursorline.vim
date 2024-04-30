"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" About:- CursorLine related configuration
" Maintainer:- vallabhdas kansagara — @vrkansagara
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Highlight current line
set cursorline

" :hi CursorLine   term=bold cterm=bold ctermbg=darkred ctermfg=white guibg=darkred guifg=white
" :hi CursorColumn term=bold cterm=bold ctermbg=darkred ctermfg=white guibg=darkred guifg=white

nnoremap <leader>c :set cursorline! cursorcolumn!<CR>
