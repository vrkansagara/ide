
" .: The current buffer
" w: Buffers in other windows
" b: Other loaded buffers
" u: Unloaded buffers
" t: Tags
" i: Included files
" complete=.,w,b,u,t,kspell

" set omnifunc=syntaxcomplete#Complete

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

set completeopt=longest,menuone,preview "completeopt=menu,preview

function! Smart_TabComplete()
	let line = getline('.')                         " current line

	let substr = strpart(line, -1, col('.')+1)      " from the start of the current
	" line to one character right
	" of the cursor
	let substr = matchstr(substr, "[^ \t]*$")       " word till cursor
	if (strlen(substr)==0)                          " nothing to match on empty string
		return "\<tab>"
	endif
	let has_period = match(substr, '\.') != -1      " position of period, if any
	let has_slash = match(substr, '\/') != -1       " position of slash, if any
	if (!has_period && !has_slash)
		return "\<C-X>\<C-P>"                         " existing text matching
	elseif ( has_slash )
		return "\<C-X>\<C-F>"                         " file matching
	else
		return "\<C-X>\<C-O>"                         " plugin matching
	endif
endfunction
inoremap <tab> <c-r>=Smart_TabComplete()<CR>

function! CleverTab()
  if pumvisible()
    return "\<C-N>"
  endif
  if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$'
    return "\<Tab>"
  elseif exists('&omnifunc') && &omnifunc != ''
    return "\<C-X>\<C-O>"
  else
    return "\<C-N>"
  endif
endfunction

" inoremap <Tab> <C-R>=CleverTab()<CR>
inoremap <silent> <TAB> <C-X><C-O>
inoremap <silent> <S-TAB> <C-X><C-O>

" autocmd FileType php call SetPHPOptions()
function! SetPHPOptions()
	" You might also find this useful
	" PHP Generated Code Highlights (HTML & SQL)                                              
	let php_sql_query=1                                                                                        
	let php_htmlInStrings=1
	set omnifunc=phpcomplete#CompletePHP
endfunction


" The above mapping will change the behavior of the <Enter> key when the popup
" menu is visible. In that case the Enter key will simply select the highlighted
" menu item, just as <C-Y> does. 
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"


" In the above mappings, the first will make <C-N> work the way it normally
" does; however, when the menu appears, the <Down> key will be simulated. What
" this accomplishes is it keeps a menu item always highlighted. This way you can
" keep typing characters to narrow the matches, and the nearest match will be
" selected so that you can hit Enter at any time to insert it. In the above
" mappings, the second one is a little more exotic: it simulates <C-X><C-O> to
" bring up the omni completion menu, then it simulates <C-N><C-P> to remove the
" longest common text, and finally it simulates <Down> again to keep a match
" highlighted. 
inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

inoremap <expr> <M-,> pumvisible() ? '<C-n>' :
  \ '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

" " open omni completion menu closing previous if open and opening new menu without changing the text
inoremap <expr> <C-Space> (pumvisible() ? (col('.') > 1 ? '<Esc>i<Right>' : '<Esc>i') : '') .
            \ '<C-x><C-o><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>'
" " open user completion menu closing previous if open and opening new menu without changing the text
inoremap <expr> <S-Space> (pumvisible() ? (col('.') > 1 ? '<Esc>i<Right>' : '<Esc>i') : '') .
            \ '<C-x><C-u><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>'


" highlight Pmenu guibg=brown gui=bold
" highlight Pmenu ctermbg=238 gui=bold
" runtime syntax/colortest.vim
"
