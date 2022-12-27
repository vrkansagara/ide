
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup filetypedetect
    au! BufRead,BufNewFile *.md   setfiletype markdown
augroup END

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5markdown()
	" Call F2 which is trim whitespace for all file type
	exe "normal \<F2>"
	" Indent whole file
	exe "normal gg=G``"
endfunction

" This function is dynamically called by hiting enter for filetype
function! Runmarkdown()
    let fileName = expand('%:t') " file name only (with extention)
    let fileNameW = expand('%:p:r') "Absolute file name only (without extention)
    let filePath = expand('%:p') " Absolute to filepath
    let directoryPath = expand('%:p:h') " Absolute to directory

    " Write current file
    execute "silent! w!"
endfunction

