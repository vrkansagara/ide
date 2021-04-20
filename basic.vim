" The escape key is a long ways away. This maps it to the sequence 'kj'
map! kj <Esc>
inoremap kj <Esc>

" With a map leader it's possible to do extra key combinations
let mapleader = ","

nnoremap <leader>v :tabedit $MYVIMRC<CR>

" Reload vimrc configuration file
nnoremap <leader>r :source $MYVIMRC<CR>

" if user want to discard all the change and close all the files then they can use :qa!
nnoremap <leader>w :w<cr>

" vimcasts #24
" Auto-reload vimrc on save
if has("autocmd")
    autocmd bufwritepost .vimrc source $MYVIMRC
endif

" like <leader>q quite/close current file
nnoremap <leader>q :confirm q<cr>


let g:netrw_banner = 0
let g:netrw_list_hide = '^\.\.\=/\=$,.DS_Store,.idea,.git,__pycache__,venv,node_modules,*\.o,*\.pyc,.*\.swp'
let g:netrw_hide = 1
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_liststyle = 4
let g:netrw_winsize = 40
let g:NetrwIsOpen=0
function! ToggleNetrw()
    if g:NetrwIsOpen
        let i = bufnr("$")
        while (i >= 1)
            if (getbufvar(i, "&filetype") == "netrw")
                silent exe "bwipeout " . i 
            endif
            let i-=1
        endwhile
        let g:NetrwIsOpen=0
    else
        let g:NetrwIsOpen=1
        silent Vex!
    endif
endfunction

" Add your own mapping. For example:
nnoremap <silent><leader><space> :call ToggleNetrw()<CR>
