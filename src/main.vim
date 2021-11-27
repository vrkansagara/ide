"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :- Main configuration file for the VIM(init)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Alt-letter will now be recognized by vi in a terminal as well as by gvim.
" The timeout settings are used to work around the ambiguity with escape
" sequences. Esc and j sent within 50ms will be mapped to <A-j>, greater than
" between Meta encoding and hitting two keys.
" 50ms will count as separate keys. That should be enough time to distinguish
let c='a'
while c <= 'z'
	exec "set <A-".c.">=\e".c
	exec "imap \e".c." <A-".c.">"
	let c = nr2char(1+char2nr(c))
endwhile
set timeout ttimeoutlen=10
set ttimeoutlen=10

" setting term to xterm ( let's use the termianal basic information)
" No need to set basic information as I am using `st` terminal
" set term=xterm
" set t_Co=256
if &term =~ '^st' || &term =~ '^screen'
	" https://superuser.com/questions/401926/how-to-get-shiftarrows-and-ctrlarrows-working-in-vim-in-tmux/402084#402084
    " tmux will send xterm-style keys when its xterm-keys option is on
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
endif

" The escape key is a long ways away. This maps it to the sequence 'kj'
map! kj <Esc>
inoremap kj <Esc>

" With a map leader it's possible to do extra key combinations
let mapleader = ","

" execute external command and past standarad output in insert mode ( CTRL+R a )
" @a is the register name
let @a = system("ls -lhtr")

nnoremap <leader>v :tabedit $MYVIMRC<CR>
nnoremap <leader>my :tabedit $HOME/.vim/src/main.vim<CR>

" vimcasts #24
" Auto-reload vimrc on save
" hotreload not require, I will do on my own.
" I like manual refresh (NO AUTO)
" if has("autocmd")
	" autocmd bufwritepost .vimrc source $MYVIMRC
" endif

" Reload vimrc configuration file
nnoremap <leader>r :source $MYVIMRC<CR>
" nnoremap <leader>r :source ~/.vim/vimrc.vim<CR>

"sudo" save: current file.
cnoremap w!! w !sudo tee % >/dev/null
nnoremap <leader>w :w<cr>

" w! Save current file with sudo access
" (useful for handling the permission-denied error)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" nnoremap <silent> <F1> Already set with guake terminal
" Do you absolutely hate trailing white space or tabs in your files? (Yes =
" Press F2)
nnoremap <silent> <F2> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>:retab<CR>:echom "White space trimed"<CR>

function! HighlightRepeats() range
"Ref :-  https://stackoverflow.com/questions/1268032/how-can-i-mark-highlight-duplicate-lines-in-vi-editor/28690847
"Singler liner :--- :syn clear Repeat | g/^\(.*\)\n\ze\%(.*\n\)*\1$/exe 'syn match Repeat "^' . escape(getline('.'), '".\^$*[]') . '$"' | nohlsearch
  let lineCounts = {}
  let lineNum = a:firstline
  while lineNum <= a:lastline
    let lineText = getline(lineNum)
    if lineText != ""
      let lineCounts[lineText] = (has_key(lineCounts, lineText) ? lineCounts[lineText] : 0) + 1
    endif
    let lineNum = lineNum + 1
  endwhile
  exe 'syn clear Repeat'
  for lineText in keys(lineCounts)
    if lineCounts[lineText] >= 2
      exe 'syn match Repeat "^' . escape(lineText, '".\^$*[]') . '$"'
    endif
  endfor

  echom "Dublicate lines are highlighted"
endfunction
command! -range=% HighlightRepeats <line1>,<line2>call HighlightRepeats()
nnoremap <silent> <F1> :HighlightRepeats<cr>

" " Toggle visually showing all white space characters.
noremap <S-F2> :set list!<CR>
inoremap <S-F2> <C-o>:set list!<CR>
cnoremap <S-F2> <C-c>:set list!<CR>

" vim regex highlight (i.e. regexPattern = "nnoremap" ) [Require :set hlsearch]
nnoremap <silent> <F3> yi":let @/ = @"<CR>

"These next three lines are for the fuzzy search:
set nocompatible      "Limit search to your project
set path+=**          "Search all subdirectories and recursively
set wildmenu          "Shows multiple matches on one line

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

" Vim move lime up and down using j and k
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" like <leader>q quite/close current file
nnoremap <leader>q :confirm q<cr>

" like <leader>Q quite/close grease fully
" nnoremap <leader>Q :qa<cr>
nnoremap <C-q> :confirm qa<cr>

" nnoremap <leader>Q :confirm qall <cr>
" Close all unchanged files(buffers)
nnoremap <leader>Q :bufdo! bw<cr>
" if user want to discard all the change and close all the files then they can use :qa!

" Use UTF-8 encoding
set encoding=utf-8

set expandtab
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

" Disable mouse usage to make life easier for developer
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
nnoremap <leader>git :cd ~/git<cr>:pwd<cr>

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

" Height of the command bar
set cmdheight=2

" Scrolling options
set scrolljump=5
set scrolloff=3

" Set column size to 80 character (standard size)
" " Make it obvious where 80 characters is ( Reformat it:gq)                   i
" Set text width to 80 character only., I am not using at this time.
set textwidth=80
set colorcolumn=+1
set wrapmargin=2
set expandtab

" au BufRead,BufNewFile *.md vim setlocal textwidth=80
" au BufRead,BufNewFile *.c *.cpp *.hc *.cpp *.h  vim setlocal textwidth=80

" set complete=.,w,b,u,t,kspell
" CTRL + o and CTRL+i back

" Profile Vim by running this command once to start it and again to stop it.
function! s:profile(bang)
	if a:bang
		profile pause
		noautocmd qall
	else
		profile start /tmp/profile.log
		profile func *
		profile file *
	endif
endfunction

command! -bang Profile call s:profile(<bang>0)

" do not print unwanted character at vim while editing
let &t_TI = ""
let &t_TE = ""

" https://github.com/vim/vim/issues/993#issuecomment-255651605
" set Vim-specific sequences for RGB colors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
