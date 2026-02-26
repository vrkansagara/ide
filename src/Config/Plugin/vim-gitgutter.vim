" ==============================================================================
" File        : vim-gitgutter.vim
" Maintainer  : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
" Version     : 2.0.0
" Description : vim-gitgutter diff signs and hunk navigation
" ==============================================================================

if exists('g:loaded_vim_gitgutter_config')
    finish
endif
let g:loaded_vim_gitgutter_config = v:true

" Use fontawesome icons as signs
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '>'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = '^'
let g:gitgutter_sign_modified_removed = '<'

let g:gitgutter_override_sign_column_highlight = 1
" highlight SignColumn guibg=bg
" highlight SignColumn ctermbg=bg

let g:gitgutter_map_keys = 0
set signcolumn=yes

" Jump between hunks

" git next/previous
nnoremap <Leader>gn <Plug>(GitGutterNextHunk)
nnoremap <Leader>gp <Plug>(GitGutterPrevHunk)

" Hunk-add and hunk-revert for chunk staging
nnoremap <Leader>gs <Plug>(GitGutterStageHunk)
nnoremap <Leader>gu <Plug>(GitGutterUndoHunk)
