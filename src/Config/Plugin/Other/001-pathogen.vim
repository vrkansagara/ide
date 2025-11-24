
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File name  :- 001-pathogen.vim                                        "
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :- Do not rename of file                                   "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Enable pathogen bundles
" See http://www.vim.org/scripts/script.php?script_id=2332
" Put github plugins under .vim/bundle/ -- which allows keeping them updated
" without having to do separate installation.

""""""""""""""""""""""""""""""
" => Load pathogen paths
""""""""""""""""""""""""""""""

" Let syntax enable later on color scheme applyied.
if exists("g:syntax_on")
    syntax off
endif

" Call "filetype off" first to ensure that bundle ftplugins can be added to the
" path before we re-enable it later in the vimrc.
filetype off

let s:vim_runtime = expand('<sfile>:p:h')."/../../.."
" let s:vim_runtime = expand("%:p:h") ."/../.."

" Vendor forlder is source of github/third party code
call pathogen#infect(s:vim_runtime.'/vendor/{}')

call pathogen#helptags()

" Enalbe file indent after plugin enables
filetype plugin indent on
