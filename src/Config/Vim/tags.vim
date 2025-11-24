" Ctrl+] - go to definition
" Ctrl+T - Jump back from the definition.
" Ctrl+W Ctrl+] - Open the definition in a horizontal split

" Add these lines in vimrc
" nnoremap <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
" nnoremap <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
" Ctrl+\ - Open the definition in a new tab
" Alt+] - Open the definition in a vertical split

" After the tags are generated. You can use the following keys to tag into and tag out of functions:
" Ctrl+Left MouseClick - Go to definition
" Ctrl+Right MouseClick - Jump back from definition 

nnoremap <C-\> :split<CR>:exec("tag ".expand("<cword>"))<CR>

" set tags^=./tags
" set tags^=./tags

" https://github.com/tpope/vim-fugitive/commit/63a05a6935ec4a45551bf141089c13d5671202a1
" :set tags^=./.git/tags; "Suggested 
set tags^=./tags;
" Navigating through multiple definition
" If you used :tag on a tag that's got multiple definitions, use these commands to sift through them all.

" Shortcut	Definition
" :tn	Move to next definition (:tnext)
" :tp	Move to previous definition (:tprevious)
" :ts	List all definitions (:tselect)
" Key shortcuts
" You can also place your cursor on some text and press ^] to jump to that tag.

" Shortcut	Definition
" ^]	Jump to definition
" ^t	Jump back from definition
" ^W }	Preview definition
" g]	See all definitions

" Select tag from tag list
" :tselect
" Move to the first tag
" :tfirst
" Move to the last tag
" :tlast
" Move to the previous tag
" :tprev
" Move to next tag
" :tnext
" Search tag by other tag commands
" :tag num
