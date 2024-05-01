"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Once CtrlP is open:
"Press <F5> to purge the cache for the current directory to get new files,
"remove deleted files and apply new ignore options.

"Press <c-f> and <c-b> to cycle between modes.
"Press <c-d> to switch to filename search instead of full path.
"Press <c-r> to switch to regexp mode.
"Use <c-j>, <c-k> or the arrow keys to navigate the result list.
"Use <c-t> or <c-v>, <c-x> to open the selected entry in a new tab or in a new
"split.
"Use <c-n>, <c-p> to select the next/previous string in the prompt's history.
"Use <c-y> to create a new file and its parent directories.
"Use <c-z> to mark/unmark multiple files and <c-o> to open them.

" Use this option to specify how the newly created file is to be opened when
" pressing <c-y>: >
" let g:ctrlp_open_new_file = 'v'

" Quickly find and open a file in the CWD
" let g:ctrlp_map = '<C-f>'
let g:ctrlp_map = '<C-P>'
let g:ctrlp_cmd = 'CtrlP'

" Quickly open all mixed files
nnoremap <C-S-f>f :CtrlPMixed<CR>

" Find and open a buffer
nnoremap <leader>b :CtrlPBuffer<cr>

" Buffer tag
nnoremap <leader>. :CtrlPBufTag<cr>

" Recently opened file
nnoremap <leader>` :CtrlPMRUFiles<cr>

" Seach recursively from the ancestor containing .git
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_lazy_update = 1
let g:ctrlp_use_caching = 1

"This will require to avoid duplication of tabs or open as buffer
let g:ctrlp_prompt_mappings = {
            \ 'AcceptSelection("e")': ['<2-LeftMouse>'],
            \ 'AcceptSelection("t")': ['<cr>'],
            \ }

let g:ctrlp_max_height = 15
let g:ctrlp_custom_ignore = {
            \ 'dir':  '\v[\/]\.(git|hg|svn|node_modules|.DS_Store|bundle)$',
            \ 'file': '\v\.(swap|so|log|tags)$',
            \ }
let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:30,results:50'

" Use ag if available for quicker searches
if executable('ag')

    " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

endif

let g:ctrlp_tabpage_position = 'ac'
let g:ctrlp_switch_buffer = 'Et'
