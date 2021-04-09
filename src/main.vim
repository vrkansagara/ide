
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" About:- Main configuration file for the VIM(init)
" Maintainer:- Vallabh Kansagara — @vrkansagara
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Alt-letter will now be recognised by vi in a terminal as well as by gvim. The timeout settings are used to work around the ambiguity with escape sequences. Esc and j sent within 50ms will be mapped to <A-j>, greater than 50ms will count as separate keys. That should be enough time to distinguish between Meta encoding and hitting two keys.
let c='a'
while c <= 'z'
  exec "set <A-".c.">=\e".c
  exec "imap \e".c." <A-".c.">"
  let c = nr2char(1+char2nr(c))
endw
set timeout ttimeoutlen=50

" The escape key is a long ways away. This maps it to the sequence 'kj'
map! kj <Esc>
inoremap kj <Esc>

set linespace=60

" With a map leader it's possible to do extra key combinations
let mapleader = ","

nnoremap <leader>v :tabedit $MYVIMRC<CR>
nnoremap <leader>my :tabedit $HOME/.vim/src/main.vim<CR>

" Reload vimrc configuration file
nnoremap <leader>r :source $MYVIMRC<CR>
" nnoremap <leader>r :source ~/.vim/vimrc.vim<CR>

" " get off my lawn
" nnoremap <up> :echoe "use k"<cr>
" nnoremap <down> :echoe "use j"<cr>
" nnoremap <left> :echoe "use h"<cr>
" nnoremap <right> :echoe "use l"<cr>

" Make Arrowkey do something usefull, resize the viewports accordingly and
" it also forces us to use the default Vim movement keys HJKL
nnoremap <Left> :vertical resize -5<CR>
nnoremap <Right> :vertical resize +5<CR>
nnoremap <Up> :resize -5<CR>
nnoremap <Down> :resize +5<CR>

" vimcasts #24
" Auto-reload vimrc on save
if has("autocmd")
    autocmd bufwritepost .vimrc source $MYVIMRC
endif

" like <leader>q quite/close current file
nnoremap <leader>q :confirm q<cr>

" like <leader>Q quite/close grease fully
" nnoremap <leader>Q :qa<cr>
nnoremap <C-q> :confirm qa<cr>

" nnoremap <leader>Q :confirm qall <cr>
" Close all unchanged files(buffers)
nnoremap <leader>Q :bufdo! bw<cr>
" if user want to discard all the change and close all the files then they can use :qa!

" "sudo" save: current file.
cnoremap w!! w !sudo tee % >/dev/null
nnoremap <leader>w :w<cr>

" w! Save current file with sudo access
" (useful for handling the permission-denied error)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" Yank text to the clipboard easier (y = yank|copy , d = delete|cut, p = paste) (Register
" *=window, + = linux) - In normal mode, one can use p to paste after the cursor, or P to paste before the cursor.
if has('clipboard')
	if has("win32")
		"Windows options here
		noremap <leader>y "*y
		noremap <leader>yy "*Y
		noremap <leader>p "*p
	else
		if has("unix")
			let s:uname = system("uname")
			if s:uname == "Darwin\n"
				"Mac options here
			elseif s:uname == "Linux\n"
				" Linux stuff
				noremap <leader>y "+y
				noremap <leader>yy "+Y
				noremap <leader>p "+p
			endif
		endif
	endif
else
	echomsg "Clipboard functionality is not present with current VIM"
endif

" Use UTF-8 encoding
set encoding=utf-8

" Set text width to 80 character only., I am not using at this time.
" set textwidth=80
set textwidth=0

set tabstop=4
set softtabstop=4
set shiftwidth=4
set ttyfast
set showcmd
set showmode
set wildmenu
set wildmode=list:longest

" Added 2005-03-23 Based on http://www.perlmonks.org/index.pl?node_id=441738
set smarttab
set shiftround
set autoindent
set smartindent

" Disable the splash screen
set shortmess +=I

" "Hidden" buffers -- i.e., don't require saving before editing another file.
" Calling quit will prompt you to save unsaved buffers anyways.
set hidden

" Disable mouse usage to make life easier a developer
set mouse-=a

" Allow better terminal/mouse integration
set mousemodel=extend

" Bash is my shell
" Well, not really. But this makes CLI integration better.
let bash_is_sh=1

" Repair weird terminal/vim settings
set backspace=start,eol,indent

" VIM Disable Automatic Newline At End Of File
set nofixendofline

" Switch CWD to the directory of the open buffer:
nnoremap <leader>cd :cd %:p:h<cr>:pwd<cr>
nnoremap <leader>tmp :cd /tmp<cr>:pwd<cr>

" Keybindings for movement in insert mode
inoremap <leader>0 <Esc>I
inoremap <leader>$ <Esc>,
inoremap <leader>$ <Esc>A
inoremap <leader>h <Esc>i
inoremap <leader>l <Esc>lli
inoremap <leader>j <Esc>lji
inoremap <leader>k <Esc>lki

" Execute last command over a visual selection
vnoremap . :norm.<CR>

" Pasting toggle...
set pastetoggle=<Ins>

" Turn off modelines
set modelines=0

" Show info in ruler
set laststatus=2

" Scrolling options
set scrolljump=5
set scrolloff=3

" Vim move lime up and down using j and k
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv


" nnoremap <F5> yi":let @/ = @"<CR>
" Set column size to 80 character (standard size)
" " Make it obvious where 80 characters is ( Reformat it:gq)
" set textwidth=80
" set colorcolumn=+1
" au BufRead,BufNewFile * setlocal textwidth=80

" set complete=.,w,b,u,t,kspell
" CTRL + o and CTRL+i back
