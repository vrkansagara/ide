"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Space conflicts with code folding.
" This only work with first directory with vim open
" nnoremap <leader><space> :NERDTreeToggle<cr>
" nnoremap <F5> :NERDTreeToggle<CR>
noremap <leader><space> :call NERDTreeToggleInCurDir()<cr>

" Direct control key conflicts with different OS (i.e. xfce)
noremap <A-p> :NERDTreeToggle<cr>

" nnoremap <leader>nb :NERDTreeFromBookmark
" nnoremap <leader>nf :NERDTreeFind<cr>

let NERDTreeMinimalUI = 3
let NERDTreeDirArrows = 1
let NERDTreeShowLineNumbers=1
let NERDTreeDirArrowExpandable = '+'
let NERDTreeDirArrowCollapsible = '-'
let NERDTreeCustomOpenArgs = {'file':{'where':'t'}}
" let NERDTreeCustomOpenArgs = {'file': {'reuse':'currenttab', 'where':'p', 'keepopen':1, 'stay':1}}
" \ '^vendor$',
let NERDTreeIgnore = [
            \'.netrwhist',
            \ '.NERDTreeBookmarks',
            \ '^node_modules$',
            \ '^.DS_Store$',
            \ '^.idea$',
            \ '^.git$',
            \ '^.coffee$',
            \ '^bundle$']

" Let always open bookmark with file explore
let NERDTreeShowBookmarks=1

" This will look for the opening of vim directory(git ignore global)
" if filereadable(".NERDTreeBookmarks")
" let g:NERDTreeBookmarksFile = ".NERDTreeBookmarks"
" endif

" Open explorer to the right side
let NERDTreeWinPos = "right"
let NERDTreeWinSize=55

" Close the pan once file is open
let NERDTreeQuitOnOpen=3
let NERDTreeAutoDeleteBuffer = 1

"" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

"" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 | let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

"" Start NERDTree when Vim is started without file arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

" Start NERDTree when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') | execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

" This function will open NERDTree into current buffer, supper easy for
" current directory
function! NERDTreeToggleInCurDir()
    "If NERDTree is open in the current buffer
    if (exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1)
        exe ":NERDTreeClose"
    else
        if (expand("%:t") != '')
            exe ":NERDTreeFind"
        else
            exe ":NERDTreeToggle"
        endif
    endif
endfunction


function NERDTreeMyOpenFile(node)
    " autocmd VimEnter * :call NERDTreeAddKeyMap({ 'key': 'o', 'callback': 'NERDTreeMyOpenFile', 'scope': 'FileNode', 'override': 1 })
    call a:node.activate({'reuse': 'currenttab', 'where': 'p'})
endfunction

function NERDTreeMyOpenInTab(node)
    " call NERDTreeAddKeyMap({ 'key': 'o', 'callback': 'NERDTreeMyOpenFile', 'scope': 'FileNode', 'override': 1 })
    call a:node.open({'reuse': "all", 'where': 't'})
endfunction

" Only set of option when nedtree buffer is active or pointer in it.
autocmd FileType nerdtree call SetNERDTreeOptions()
function! SetNERDTreeOptions()
    " nnoremap <F5> :NERDTreeRefreshRoot<CR>
    " nmap <buffer> <left> o
    " nmap <buffer> <right> o
    nmap <buffer> <S-right> T: <ESC>
    " autocmd VimEnter * :call NERDTreeAddKeyMap({'key': 't', 'callback': 'NERDTreeMyOpenInTab', 'scope': 'FileNode', 'override': 1 })
    call NERDTreeAddKeyMap({'key': 't', 'callback': 'NERDTreeMyOpenInTab', 'scope': 'FileNode', 'override': 1 })
endfunction

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5nerdtree()
    exe ":NERDTreeRefreshRoot"
endfunction

