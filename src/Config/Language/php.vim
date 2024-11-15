"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :- PHP Related stuff
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" PHP parser check (CTRL + l)
" autocmd FileType php noremap <C-l> :w%!<cr>!php -l %<CR>
autocmd FileType php noremap <Leader>l :w!<CR>:!php -l %<CR>

" run file with PHP CLI (CTRL-m) ( called as ENTER)
" autocmd FileType php noremap <C-m> :w!<CR>:! echo '\033[0m'<CR>:!php %<CR>
autocmd FileType php  nnoremap <F8> :!clear <CR> :call PhpCsCheck()<CR>
autocmd FileType php  nnoremap <F9> :!clear <CR> :call PhpCsFix()<CR>

" .inc, phpt, phtml, phps files as PHP
autocmd BufNewFile,BufRead *.inc set ft=php
autocmd BufNewFile,BufRead *.phpt set ft=php
autocmd BufNewFile,BufRead *.phtml set ft=php
autocmd BufNewFile,BufRead *.phps set ft=php
autocmd BufNewFile,BufRead *.blade.php set ft=blade

function! PhpCsCheck()
    try
    " exec "!./vendor/bin/phpcs ". expand('%:p')
    exec "! ~/.vim/vendor/bin/phpcs -s --standard= ~/.vim/phpcs.xml ". expand('%:p')
    catch
    " echo "\n" . 'Caught "' . v:exception . '" in ' . v:throwpoint ."\n"
    throw :exception
    endtry
    endfunction


function! PhpCsFix()
    try
call PhpCsCheck()
    exec "! ~/.vim/vendor/bin/phpcbf ". expand('%:p')
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

    execute "retab"
    " execute "silent! call PhpSortUse()"

    " Clear messages for better visibility (for vim)
    " exec "messages clear"

    " Call intelephense to refresh php (Manyally) not needed if it auto
    " exe "CocCommand intelephense.index.workspace"

    " reindent whole file without losing current " position
    " execute "normal gg=G``"
    " Do not loose the cursor possition
    " execute "normal ``"
    endfunction

    " This function is dynamically called by hitting  enter for filetype
function! Runphp()

    let fileName = expand('%:t') " file name only (with extension)
    let fileNameW = expand('%:p:r') "Absolute file name only (without extension)
    let filePath = expand('%:p') " Absolute to filepath
    let directoryPath = expand('%:p:h') " Absolute to directory

    " Write current file
    execute "silent! retab"
    execute "silent! w!"

    " Clear terminal color, clean screen, run object
    " execute "silent! !clear'"

    " run php file using unix less to pip the output
    execute "!php " . filePath

    " past output using "xp
    " execute "!fzf | " . system("php " . shellescape(filePath))

    endfunction

