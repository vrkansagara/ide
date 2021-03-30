" Ctrl+] - go to definition
" Ctrl+T - Jump back from the definition.
" Ctrl+W Ctrl+] - Open the definition in a horizontal split

" Add these lines in vimrc
" nnoremap <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
" nnoremap <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
" Ctrl+\ - Open the definition in a new tab
" Alt+] - Open the definition in a vertical split

nnoremap <C-\> :split<CR>:exec("tag ".expand("<cword>"))<CR>
