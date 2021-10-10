
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note		 :- GCC compiler related configuration.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" autocmd BufNewFile,BufRead *.c *.cpp *.h set ft=c

" au BufEnter *.c compiler gcc
" au BufEnter *.cpp compiler gcc
" au BufEnter *.h compiler gcc

" Linux kernal comiplation using this commit standard
" https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=51b97e354ba9fce1890cf38ecc754aa49677fc89
" run file with gnu compiler

" This warning is enabled -Wall
" autocmd FileType c noremap <C-M> :w!<CR>:! mkdir -p /tmp/%<CR>:!/usr/bin/gcc %
" -Wall = Show all possible warning, -g = Include debug information
autocmd FileType c noremap <C-M> :w!<CR>:! mkdir -p /tmp/%<CR>:!/usr/bin/gcc
			\ -g
			\ `pkg-config --cflags gtk+-3.0`
			\ -Wall
			\ -Wmissing-prototypes
			\ -Wstrict-prototypes
			\ -O2
			\ -fomit-frame-pointer
			\ -std=gnu89
			\ -o /tmp/%.out $(mysql_config --cflags) % $(mysql_config --libs) `pkg-config --libs gtk+-3.0` -lcurl && /tmp/%.out<CR>