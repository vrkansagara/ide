"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" About:- search related configuration
" Maintainer:- vallabhdas kansagara — @vrkansagara
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Turn on "very magic" regex status by default for searches.
" :he /magic for more information
nnoremap / /\v
vnoremap / /\v

" Highlight Searches
set highlight=lub
nnoremap <leader>s :set hlsearch<CR>
nnoremap <leader>S :set nohlsearch<CR>

set incsearch
set showmatch

" Make case-insensitive search the norm
set ignorecase
set smartcase


function! s:VSetSearch()
	let temp = @@
	norm! gvy
	let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
	let @@ = temp
endfunction

" Vim pr0n: Visual search mappings(  search for the word under the cursor, press *=next,#=previous )
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

nnoremap <F3> yi":let @/ = @"<CR>
