"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" About:- JavaScript related configuration
" Maintainer:- Vallabh Kansagara — @vrkansagara
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" JSHint (<Leader> l when in a JS file)
:autocmd FileType javascript noremap <Leader>l :!jshint %<CR>


" 2-space tab-width for JS
:autocmd FileType javascript set shiftwidth=2 tabstop=2 softtabstop=2
