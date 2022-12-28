"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" .sh files as Shell script
autocmd BufNewFile,BufRead *.rs set ft=rust

" Let's rust formater handle this
" https://github.com/rust-lang/rust.vim#formatting-with-rustfmt
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0
let g:rust_clip_command = 'xclip -selection clipboard'

" This function is dynamically called by Pressing F5 by (filetype.vim)
function! RefreshF5rust()
    " Call F2 which is trim whitespace for all file type
    exe "normal \<F2>"
    " Indent file ( Not needed as Rust has it's own vim-package ( rustfmt )
    " exe 'normal gg=G``'
endfunction

" This function is dynamically called by hiting enter for filetype
function! Runrust()
    let fileName = expand('%:t') " file name only (with extention)
    let fileNameW = expand('%:p:r') "Absolute file name only (without extention)
    let filePath = expand('%:p') " Absolute to filepath
    let directoryPath = expand('%:p:h') " Absolute to directory

    execute "silent ! mkdir -p /tmp". directoryPath
    let outputpath =  "/tmp" . fileNameW . ".o"

    " This warning is enabled -Wall
    " -Wall = Show all possible warning, -g = Include debug information
    " Linux kernal comiplation using this commit standard
    " https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=51b97e354ba9fce1890cf38ecc754aa49677fc89
    " run file with gnu compiler
    let compiler_options = " "
    let output_options = " -o ". outputpath

    " Write current file
    execute "silent! w!"

    " compile current file with gcc options
    execute "silent ! rustc " . compiler_options . filePath . output_options

    " Clear terminal color, clean screen, run object
    " execute "! echo -e '\033[0m' && clear && " . outputpath
    execute "! echo -e '\033[0m' && " . outputpath
endfunction
