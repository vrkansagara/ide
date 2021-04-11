set foldmethod=indent
set foldnestmax=10
" set nofoldenable " All folds are open
set foldenable   " All folds are closed as per foldlevel
set foldlevel=1


" Folding
" Toggle folding with spacebar instead of za
nnoremap <space> za
nnoremap <S-space> zM


" Following will prevent vim from closing folds in a current pane when opening a
" new pane.
" See http://stackoverflow.com/posts/30618494/revisions
autocmd InsertLeave,WinEnter * setlocal foldmethod=syntax
autocmd InsertEnter,WinLeave * setlocal foldmethod=manual


" set foldmethod=expr foldexpr=getline(v:lnum)=~'^\\s*'.&commentstring[0]
autocmd FileType c      setlocal foldmethod=expr foldexpr=getline(v:lnum)=~'^\\s*//'
autocmd FileType python setlocal foldmethod=expr foldexpr=getline(v:lnum)=~'^\\s*#'

autocmd FileType php	setlocal foldmethod=expr foldexpr=getline(v:lnum)=~'^\\s*//'
autocmd FileType php	setlocal foldmethod=expr foldexpr=getline(v:lnum)=~'^\\s*#'


