"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" About:- mustache related configuration
" Maintainer:- Vallabh Kansagara — @vrkansagara
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" mustache.vim settings
if has("autocmd")
    au  BufnewFile,BufRead *.mustache set syntax=mustache
endif