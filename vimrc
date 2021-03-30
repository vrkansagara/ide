" The escape key is a long ways away. This maps it to the sequence 'kj'
map! kj <Esc>
inoremap kj <Esc>

" With a map leader it's possible to do extra key combinations
let mapleader = ","

" edit vimrc file
nnoremap <leader>v :tabedit $MYVIMRC<CR>

" Reload vimrc configuration file
nnoremap <leader>r :source $MYVIMRC<CR>

" "sudo" save: current file.
cnoremap w!! w !sudo tee % >/dev/null
nnoremap <leader>w :w<cr>


" vimcasts #24
" Auto-reload vimrc on save
if has("autocmd")
    autocmd bufwritepost .vimrc source $MYVIMRC
endif

" like <leader>q quite current file
nnoremap <leader>q :q<cr>
" like <leader>Q quite gresss fully
nnoremap <leader>Q :qa<cr>

"================================================

" enter the current millenium
set nocompatible

" enable syntax and plugins (for netrw)
syntax enable
filetype plugin on

" FINDING FILES:

" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=**

" Display all matching files when we tab complete
set wildmenu


" Create the `tags` file (may need to install ctags first)
command! MakeTags !ctags -R .


" ++-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+--+-+-
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 3
let g:netrw_altv = 1
let g:netrw_winsize = 25
let g:netrw_chgwin=1

" Open file explorer at right side
":nnoremap <leader><Space> :Vex! .<cr>
" Open file explorer at top side
" :nnoremap <leader>nn :Hex! .<cr>

" augroup ProjectDrawer
"  autocmd!
"  autocmd VimEnter * :Vexplore!
" augroup END


" Toggle Vexplore with Ctrl-E
function! ToggleVExplorer()
  if exists("t:expl_buf_num")
      let expl_win_num = bufwinnr(t:expl_buf_num)
      if expl_win_num != -1
          let cur_win_nr = winnr()
          exec expl_win_num . 'wincmd w'
          close
          exec cur_win_nr . 'wincmd w'
          unlet t:expl_buf_num
      else
          unlet t:expl_buf_num
      endif
  else
      exec '1wincmd w'
      Vexplore
      let t:expl_buf_num = bufnr("%")
  endif
endfunction
" map <silent> <C-E> :call ToggleVExplorer()<CR>
map <silent> <leader><space> :call ToggleVExplorer()<CR>


