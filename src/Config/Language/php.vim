"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :- PHP Related stuff
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" PHP parser check (CTRL + l)
" autocmd FileType php noremap <C-l> :w!<cr>:! echo -e "\033[0m" && /usr/bin/clear<CR>:!php -l %<CR>

" run file with PHP CLI (CTRL-m) ( called as ENTER)
" autocmd FileType php noremap <C-m> :w!<CR>:! echo '\033[0m'<CR>:!php %<CR>
autocmd FileType php  nnoremap <F8> :! echo -e'\033[0m' <CR>:call PhpCsCheck()<CR>
autocmd FileType php  nnoremap <F9> :! echo -e'\033[0m' <CR>:call PhpCsFix()<CR>

" .inc, phpt, phtml, phps files as PHP
autocmd BufNewFile,BufRead *.inc set ft=php
autocmd BufNewFile,BufRead *.phpt set ft=php
autocmd BufNewFile,BufRead *.phtml set ft=php
autocmd BufNewFile,BufRead *.phps set ft=php
autocmd BufNewFile,BufRead *.blade.php set ft=php

function! PhpCsCheck()
    try
        " exec "!./vendor/bin/phpcs ". expand('%:p')
        exec "!~/.vim/vendor/bin/phpcs ". expand('%:p')
    catch
        " echo "\n" . 'Caught "' . v:exception . '" in ' . v:throwpoint ."\n"
        throw :exception
    endtry
endfunction


function! PhpCsFix()
    try
        call PhpCsCheck()
        exec "!~/.vim/vendor/bin/phpcbf ". expand('%:p')
    catch
        " echo "\n" . 'Caught "' . v:exception . '" in ' . v:throwpoint ."\n"
        throw :exception
    endtry
endfunction

"Sort PHP use statements ( This is already done using php-name
"http://stackoverflow.com/questions/11531073/how-do-you-sort-a-range-of-lines-by-length
" vmap <Leader>su ! awk '{ print length(), $0 \| "sort -n \| cut -d\\  -f2-" }'<cr>

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5php()
    " Call F2 which is trim whitespace for all file type
    exe "normal \<F2>"

    " reindent whole file without losing current " position
    " exe "normal gg=G``"
	execute "PrettierAsync"

    " Clear messages for better visibility (for vim)
    exec "messages clear"

	" Call intelephense to refresh php (Manyally) not needed if it auto
	" exe "CocCommand intelephense.index.workspace"

    " PHP Performance (insted of " use ')
    " silent! %s/\"\([^"]*\)\"/'\1'/g
endfunction

" This function is dynamically called by hiting enter for filetype
function! Runphp()
    let file_name = expand('%p')
	exe "!php " . file_name
endfunction
