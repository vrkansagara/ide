
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note		 :- netrw-quickmap
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Map ,n to open netrw in the current working directory
nnoremap <Leader>n :edit .<CR>

" hide netrw top message
let g:netrw_banner=1
" tree listing by default
let g:netrw_liststyle=3
" hide vim swap files
let g:netrw_list_hide="^\.sw.*$,^\.*\.sw.*$,^\..*\.un[~]$"
" open files in left window by default
let g:netrw_altv          = 1
let g:netrw_browse_split = 3
let g:netrw_chgwin=1
let g:netrw_fastbrowse    = 2
let g:netrw_keepdir       = 0
let g:netrw_retmap        = 1
let g:netrw_silent        = 1
let g:netrw_sort_by		  ="name"
let g:netrw_sort_direction="normal"
let g:netrw_sort_options = "i"
let g:netrw_special_syntax= 1
let g:netrw_localcopydircmd = 'cp -rv'
hi! link netrwMarkFile Search

" remap shift-enter to fire up the sidebar
" nnoremap <silent> <S-CR> :rightbelow 20vs<CR>:e .<CR>
" the same remap as above - may be necessary in some distros
"nnoremap <silent> <C-M> :rightbelow 20vs<CR>:e .<CR>
" remap control-enter to open files in new tab
"nmap <silent> <C-CR> t :rightbelow 20vs<CR>:e .<CR>:wincmd h<CR>
" the same remap as above - may be necessary in some distros
"nmap <silent> <NL> t :rightbelow 20vs<CR>:e .<CR>:wincmd h<CR>

" Open file explorer at right side
":nnoremap <leader><Space> :Vex! .<cr>
" Open file explorer at top side
" :nnoremap <leader>nn :Hex! .<cr>

" Define mappings.
augroup NetrwOpenMultiTabGroup
autocmd!
autocmd Filetype netrw vnoremap <buffer> <silent> <expr> t ":call NetrwOpenMultiTab(" . line(".") . "," . "v:count)\<CR>"
autocmd Filetype netrw vnoremap <buffer> <silent> <expr> T ":call NetrwOpenMultiTab(" . line(".") . "," . (( v:count == 0) ? '' : v:count) . ")\<CR>"
augroup END

let g:netrw_banner = 0
let g:netrw_list_hide = '^\.\.\=/\=$,.DS_Store,.idea,.git,__pycache__,venv,node_modules,*\.o,*\.pyc,.*\.swp'
let g:netrw_hide = 1
let g:netrw_browse_split = 4
let g:netrw_winsize = 40
let g:NetrwIsOpen=0

" Per default, netrw leaves unmodified buffers open.  This autocommand
" deletes netrw's buffer once it's hidden (using ':q;, for example)
autocmd FileType netrw setl bufhidden=delete  " or use :qa!

" Add your own mapping. For example:
nnoremap <silent><leader><space> :call ToggleNetrw()<CR>
" https://vi.stackexchange.com/a/13351/2917
function! NetrwOpenMultiTab(current_line,...) range
" Get the number of lines.
let n_lines =  a:lastline - a:firstline + 1

" This is the command to be built up.
let command = "normal "

" Iterator.
let i = 1

" Virtually iterate over each line and build the command.
while i < n_lines
let command .= "tgT:" . ( a:firstline + i ) . "\<CR>:+tabmove\<CR>"
let i += 1
endwhile
let command .= "tgT"

" Restore the Explore tab position.
if i != 1
let command .= ":tabmove -" . ( n_lines - 1 ) . "\<CR>"
endif

" Restore the previous cursor line.
let command .= ":" . a:current_line  . "\<CR>"

" Check function arguments
if a:0 > 0
if a:1 > 0 && a:1 <= n_lines
" The current tab is for the nth file.
let command .= ( tabpagenr() + a:1 ) . "gt"
else
" The current tab is for the last selected file.
let command .= (tabpagenr() + n_lines) . "gt"
endif
endif
" The current tab is for the Explore tab by default.

" Execute the custom command.
execute command
endfunction


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

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5netrw()
	exe "normal \<c-l>"
	" if &ft ==# "netrw"
	" your code here
	" endif
	endfunction
