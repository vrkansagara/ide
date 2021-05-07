
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note		 :- GCC compiler related configuration.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

au BufEnter *.c compiler gcc
au BufEnter *.cpp compiler gcc
au BufEnter *.h compiler gcc

" Linux kernal comiplation using this commit standard
" https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=51b97e354ba9fce1890cf38ecc754aa49677fc89
" run file with gnu compiler

" This warning is enabled -Wall
" autocmd FileType c noremap <C-M> :w!<CR>:! mkdir -p /tmp/%<CR>:!/usr/bin/gcc %
autocmd FileType c noremap <C-M> :w!<CR>:!/usr/bin/gcc %
			\ -Wall
			\ -Wmissing-prototypes
			\ -Wstrict-prototypes
			\ -O2
			\ -fomit-frame-pointer
			\ -std=gnu89
			\ -o /tmp/%.out && /tmp/%.out<CR>
