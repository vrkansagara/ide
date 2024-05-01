"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note       :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! CLoseAllPossibleFoldMethod()
	" Lets cloase all possible folds
	execute "normal zM"
endfunction


" All folds are closed as per foldlevel
set foldenable
set foldlevel=5
set foldmethod=indent
set foldnestmax=10
" set nofoldenable " All folds are open
call CLoseAllPossibleFoldMethod()

" Code Folding
" Toggle folding with spacebar instead of za
" nnoremap <silent><nowait> <space> zM  " Close all folds
" nnoremap <silent><nowait> <space> za  " Open fold recursive under cursor
" nnoremap <silent><nowait> <space><space> zR " Open all fold of file

"Toggle folding with spacebar instead of za
" When on a closed fold: open it.  When folds are nested, you may have to use "za" several times.
nnoremap <silent><nowait> <space> za

"  Open all folds.  This sets 'foldlevel' to highest fold level.
nnoremap <silent><nowait> <space><space> zR

" Following will prevent vim from closing folds in a current pane when opening a
" new pane.
" See http://stackoverflow.com/posts/30618494/revisions
autocmd InsertLeave,WinEnter * setlocal foldmethod=syntax
autocmd InsertEnter,WinLeave * setlocal foldmethod=manual

" set foldmethod=expr foldexpr=getline(v:lnum)=~'^\\s*'.&commentstring[0]
autocmd FileType c      setlocal foldmethod=expr foldexpr=getline(v:lnum)=~'^\\s*//'
autocmd FileType python setlocal foldmethod=expr foldexpr=getline(v:lnum)=~'^\\s*#'
autocmd FileType php    setlocal foldmethod=expr foldexpr=getline(v:lnum)=~'^\\s*//'
autocmd FileType php    setlocal foldmethod=expr foldexpr=getline(v:lnum)=~'^\\s*#'
autocmd FileType txt    setlocal nofoldenable
autocmd FileType conf   setlocal nofoldenable
autocmd FileType markdown   setlocal nofoldenable
autocmd FileType json	setlocal foldmethod=syntax

" Toggle method used for folding
nnoremap mm :call ToggleFoldMethod()<CR>
function! ToggleFoldMethod()
	if &foldmethod == 'indent'
        set foldmethod=marker
        echo "foldmethod=marker"
	else
        set foldmethod=indent
        echo "foldmethod=indent"
	endif
	call CLoseAllPossibleFoldMethod()
endfunction

