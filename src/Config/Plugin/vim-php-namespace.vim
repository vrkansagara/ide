" vim-php-namespace
" Map <leader>u to insert a 'use' statement for the class name currently under
" the cursor
" Commented out 2017-07-12; phpactor provides this.
function! IPhpInsertUse()
    call PhpInsertUse()
    call feedkeys('a',  'n')
endfunction
autocmd FileType php inoremap <Leader>u <Esc>:call IPhpInsertUse()<CR>
autocmd FileType php noremap <Leader>u :call PhpInsertUse()<CR>

" Map <leader>e to expand the class name under the cursor to its FQCN
function! IPhpExpandClass()
    call PhpExpandClass()
    call feedkeys('a', 'n')
endfunction
autocmd FileType php inoremap <Leader>e <Esc>:call IPhpExpandClass()<CR>
autocmd FileType php noremap <Leader>e :call PhpExpandClass()<CR>

" Map <leader>s to sort the various 'use' statements (As filetype is calling
" on save and on load so no need any key bindings)
" autocmd FileType php inoremap <Leader>s <Esc>:call PhpSortUse()<CR>
" autocmd FileType php noremap <Leader>s :call PhpSortUse()<CR>

" Ensure any inserted 'use' statements are sorted correctly
let g:php_namespace_sort_after_insert = 1
