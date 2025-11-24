"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" About:- spell related configuration
" Maintainer:- vallabhdas kansagara — @vrkansagara
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set spell spelllang=en_gb
set spellfile=~/.vim/data/spell/en.utf-8.add

" Enable spell check
nnoremap <leader>ss :setlocal spell spelllang=en_gb<cr>

" Disable spell check
nnoremap <leader>ss! :set nospell<cr>

nnoremap <leader>sn ]s " Next
nnoremap <leader>sp [s " Previous
nnoremap <leader>sa zg " Add
nnoremap <leader>s? z= " Suggest

" Map <leader>ss to turn spelling on (VIM 7.0+)
":for item in ['Bad','Cap','Local','Rare']| exe "hi Spell".item| enfor " Print current value

hi  SpellBad cterm=underline ctermfg=none ctermbg=none term=Reverse gui=undercurl guisp=Red
hi  SpellCap cterm=underline ctermfg=none ctermbg=none term=Reverse gui=undercurl guisp=Red
hi  SpellLocal cterm=underline ctermfg=none ctermbg=none term=Reverse gui=undercurl guisp=Red
hi  SpellRare cterm=underline ctermfg=none ctermbg=none term=Reverse gui=undercurl guisp=Red

" File type specific autocmd
if exists("spellfile")
    autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_gb
    autocmd BufRead,BufNewFile *.txt setlocal spell spelllang=en_gb
endif

" Autocomplete with dictionary words when spell check is on
set complete+=kspell
