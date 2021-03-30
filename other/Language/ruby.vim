"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" About:- ruby related configuration
" Maintainer:- Vallabh Kansagara — @vrkansagara
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Run file with Ruby interpreter
:autocmd FileType ruby noremap <C-M> :w!<CR>:!ruby %<CR>