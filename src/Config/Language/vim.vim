" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5vim ()

    " Call F2 which is trim whitespace for all file type
    exe "normal \<F2>"

    " Indent whole file
    " Vim indetation is not so good
    " exe "normal gg=G``"

    " Clear messages for better visibility
    exec "messages clear"

    " Remove : from every first line
    silent! %s/^\s*://

    " silent! %s/^map/nnoremap/
    " silent! %s/^imap/inoremap/
    silent! %s/^nmap/nnoremap/
    silent! %s/^cmap/cnoremap/

    endfunction


    " This function is dynamically called by hitting  enter for filetype
function! Runvim()
    " Write current file
    execute "silent! w!"

    execute "silent!  source $MYVIMRC"

    endfunction
