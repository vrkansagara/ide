
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara " 
" Note		 :- 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" PHP parser check (CTRL + l)
autocmd FileType php noremap <C-l> :w!<CR>:! echo -e "\033[0m" /usr/bin/clear && php -l %<CR>

" run file with PHP CLI (CTRL-m)
autocmd FileType php noremap <C-m> :w!<CR>:!php %<CR>

autocmd FileType php  nnoremap <F8> :call PhpCsCheck()<CR>
autocmd FileType php  nnoremap <F9> :call PhpCsFix()<CR>

" .inc, phpt, phtml, phps files as PHP
autocmd BufNewFile,BufRead *.inc set ft=php
autocmd BufNewFile,BufRead *.phpt set ft=php
autocmd BufNewFile,BufRead *.phtml set ft=php
autocmd BufNewFile,BufRead *.phps set ft=php
autocmd BufNewFile,BufRead *.blade.php set ft=php

function! PhpCsCheck()
    try
        exec "!./vendor/bin/phpcs ". expand('%:p')
    catch
        " echo "\n" . 'Caught "' . v:exception . '" in ' . v:throwpoint ."\n"
        throw :exception
    endtry
    return 1
endfunction


function! PhpCsFix()
    try
        call PhpCsCheck()
        exec "!./vendor/bin/phpcbf ". expand('%:p')
    catch
        " echo "\n" . 'Caught "' . v:exception . '" in ' . v:throwpoint ."\n"
        throw :exception
    endtry
    return 1
endfunction
" :set omnifunc=phpcomplete#CompletePHP

"Sort PHP use statements ( This is already done using php-name
"http://stackoverflow.com/questions/11531073/how-do-you-sort-a-range-of-lines-by-length
" vmap <Leader>su ! awk '{ print length(), $0 \| "sort -n \| cut -d\\  -f2-" }'<cr>
