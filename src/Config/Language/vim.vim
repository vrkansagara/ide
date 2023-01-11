" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5vim ()
    " Remove : from every first line
    silent! %s/^\s*://
    " silent! %s/^map/nnoremap/
    " silent! %s/^imap/inoremap/
    silent! %s/^nmap/nnoremap/
    silent! %s/^cmap/cnoremap/

    " Call F2 which is trim whitespace for all file type
    exe "normal \<F2>"

    " Indent whole file
    exe "normal gg=G``"

    " Clear messages for better visibility
    exec "messages clear"
endfunction


" This function is dynamically called by hiting enter for filetype
function! Runvim()
    let fileName = expand('%:t') " file name only (with extention)
    let fileNameW = expand('%:p:r') "Absolute file name only (without extention)
    let filePath = expand('%:p') " Absolute to filepath
    let directoryPath = expand('%:p:h') " Absolute to directory

    " Write current file
    execute "silent! w!"
endfunction
