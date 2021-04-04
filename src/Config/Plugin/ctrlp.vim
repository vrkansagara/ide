"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File name :- ctrlp.vim
" About:- Active fork of kien/ctrlp.vim—Fuzzy file, buffer, mru, tag, etc finder.
" Maintainer:- Vallabh Kansagara — @vrkansagara
" web :-  https://kien.github.io/ctrlp.vim/
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"Once CtrlP is open:
"Press <F5> to purge the cache for the current directory to get new files, remove deleted files and apply new ignore options.
"Press <c-f> and <c-b> to cycle between modes.
"Press <c-d> to switch to filename search instead of full path.
"Press <c-r> to switch to regexp mode.
"Use <c-j>, <c-k> or the arrow keys to navigate the result list.
"Use <c-t> or <c-v>, <c-x> to open the selected entry in a new tab or in a new split.
"Use <c-n>, <c-p> to select the next/previous string in the prompt's history.
"Use <c-y> to create a new file and its parent directories.
"Use <c-z> to mark/unmark multiple files and <c-o> to open them.
" Use this option to specify how the newly created file is to be opened when
" pressing <c-y>: >
  " let g:ctrlp_open_new_file = 'v'
" <
  " t - in a new tab.
  " h - in a new horizontal split.
  " v - in a new vertical split.
  " r - in the current window.

" Quickly find and open a file in the CWD
" let g:ctrlp_map = '<C-f>'
let g:ctrlp_map = '<C-P>'
let g:ctrlp_cmd = 'CtrlP'

" Quickly find and open a recently opened file

nnoremap <C-S-f>f :CtrlPMixed<CR>

" Quickly find and open a buffer
nnoremap <leader>b :CtrlPBuffer<cr>
nnoremap <leader>. :CtrlPBufTag<cr>
nnoremap <leader>` :CtrlPMRUFiles<cr>

" Seach recursively from the ancestor containing .git
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_lazy_update = 1
let g:ctrlp_use_caching = 1

"let g:ctrlp_prompt_mappings = {
"    \ 'AcceptSelection("e")': ['<2-LeftMouse>'],
"    \ 'AcceptSelection("t")': ['<cr>'],
"    \ }

let g:ctrlp_max_height = 15
let g:ctrlp_custom_ignore = 'node_modules\|^\.DS_Store\|^\.git\|^\.coffee|^\vendor|^\bundle'

let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:30,results:30'
