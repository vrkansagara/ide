" plugin supertab
" Ref:- https://vim.fandom.com/wiki/Make_Vim_completion_popup_menu_work_just_like_in_an_IDE
" Hit <CR> or CTRL-] on the completion type you wish to switch to.
" Use :help ins-completion for more information.

" |<c-n>|      - Keywords in 'complete' searching down.
" |<c-p>|      - Keywords in 'complete' searching up (SuperTab default).
" |<c-x><c-l>| - Whole lines.
" |<c-x><c-n>| - Keywords in current file.
" |<c-x><c-k>| - Keywords in 'dictionary'.
" |<c-x><c-t>| - Keywords in 'thesaurus', thesaurus-style.
" |<c-x><c-i>| - Keywords in the current and included files.
" |<c-x><c-]>| - Tags.
" |<c-x><c-f>| - File names.
" |<c-x><c-d>| - Definitions or macros.
" |<c-x><c-v>| - Vim command-line.
" |<c-x><c-u>| - User defined completion.
" |<c-x><c-o>| - Omni completion.
" |<c-x>s|     - Spelling suggestions.

" let g:SuperTabDefaultCompletionType = "<c-n>"
let g:SuperTabDefaultCompletionType = "<C-X><C-O>"
set completeopt=longest,menuone  "completeopt=menu,preview


inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

inoremap <expr> <M-,> pumvisible() ? '<C-n>' :
  \ '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

" open omni completion menu closing previous if open and opening new menu without changing the text
inoremap <expr> <C-Space> (pumvisible() ? (col('.') > 1 ? '<Esc>i<Right>' : '<Esc>i') : '') .
            \ '<C-x><C-o><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>'
" open user completion menu closing previous if open and opening new menu without changing the text
inoremap <expr> <S-Space> (pumvisible() ? (col('.') > 1 ? '<Esc>i<Right>' : '<Esc>i') : '') .
            \ '<C-x><C-u><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>'


" highlight Pmenu guibg=brown gui=bold
" highlight Pmenu ctermbg=238 gui=bold
" runtime syntax/colortest.vim
