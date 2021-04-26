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
set tags^=./tags;
