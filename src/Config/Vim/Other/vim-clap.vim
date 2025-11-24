
" Clap configuration
" Allows to search through various places (Buffers, history, git changes,
" etc). It also respects current theme when searching. This configuration
" makes it go to the top of the buffer, take 70% of the current width and
" be centralized
let g:clap_layout = { 'width': '70%', 'col': '15%', 'row': '10%', 'relative': 'editor' }

" When in normal mode, press `bb` and it will call vim-clap to show current
" open buffers which we can switch to. The <CTRL>+V & <CTRL>+H shortcuts to
" vertical/horizontal split file opening also work.
nmap <silent> bb :Clap buffers<CR>
