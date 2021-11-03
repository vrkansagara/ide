"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" This file will be loaded by vim by default
" Ref: - https://github.com/vim/vim/blob/master/runtime/filetype.vim
" If vim not detect file type user can add it manually
" Vim script
if exists("did_load_filetypes")
    echoerr "did_load_filetype"
    finish
endif

augroup filetypedetect
    au! BufRead,BufNewFile *.foo,*.bar,*.baz        setfiletype fooBarBaz
    au! BufRead,BufNewFile nginx.conf   setfiletype nginx
augroup END

" :autocmd FileType vim autocmd BufWritePost <buffer> call OnFileSave()
" Pre = onLoad , Post = afterSave
" autocmd BufWritePre <buffer> :call OnFileSave()
autocmd BufWritePost <buffer> :call OnFileSave()


function! OnFileSave()
    let ext = &filetype
    let file_name = expand('%:t:r')
    let extension = expand('%:e')

    " Remove last word of each line ( %s/\s*\w\+\s*$// )
    " Remove last character of each line ( %s/.\{1}$// )
    if ext == 'vim'
        " Remove : from every first line
        silent! %s/^\s*://
        " silent! %s/^map/nnoremap/
        " silent! %s/^imap/inoremap/
        silent! %s/^nmap/nnoremap/
        silent! %s/^cmap/cnoremap/

    elseif extension == 'php'
        exe "normal \<F5>"
        " Remove closing tag(?>) from every *.php file only TODO
        " PHP Performance (insted of " use ')
        " silent! %s/\"\([^"]*\)\"/'\1'/g
        " silent! %s/\s\+$//g
        " silent! call PhpSortUse()
        " silent! call PhpCsFixerFixFile()
    endif

    " Remove white space from all file type
    silent! %s/\s\+$//e

endfunction

" How to pipe vim buffer contents via shell command and write output to split
" window
command! FW call FilterToNewWindow('myscript')
function! FilterToNewWindow(script)
    let TempFile = tempname()
    let SaveModified = &modified
    exe 'w ' . TempFile
    let &modified = SaveModified
    exe 'split ' . TempFile
    exe '%! ' . a:script
endfunction

" You can refresh filetype buffer as own your own.
nnoremap <F5> :! echo -e'\033[0m' <CR>:call CallLanguageSpecifiF5()<CR>
function! CallLanguageSpecifiF5()
    " (1) To reindent many files, the argument list can be used:
    " :args *.c
    " :argdo normal gg=G
    " :wall
    "
    "(2)  Or use the buffer list (caution, every buffer will be affected):
    ":bufdo normal gg=G
    " :wall
    " (3) How to open files with pattern recursively in vim and execute one
    " command
    " :args /yourfolder/myfile*
    " :args /yourfolder/**/myfile*
    " :args /yourfolder/**/*.c
    " :argdo tabe " Open all marked files into tabs
    " :argdo normal gg=G``  " vim style indent all files
    " :wall " write all modified files


    let ext = &filetype " php, conf
    let file_name = expand('%:t:r')
    let extension = expand('%:e') " php,phtml,php5,h, vim, c ,cpp, js

    " This is dynamic function for all the file type.
    " i.e. (1) filetype php , function name = RefreshF5php()
    " i.e. (2) filetype vim,  function name = RefreshF5vim()

    let function_name = "RefreshF5" . ext
    if exists("*". function_name)
        exe "call " . function_name ."()"
    else
        echoerr function_name 'does not exitsts'
    endif

    " Remove white space from all file type
    silent! %s/\s\+$//e

endfunction
