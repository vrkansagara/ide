"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara "
" Note		 :-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" This file will be loaded by vim by default
" Ref: - https://github.com/vim/vim/blob/master/runtime/filetype.vim
" If vim not detect file type user can add it manually
" Vim script
if exists("did_load_filetypes")
	finish
endif

augroup filetypedetect
	au! BufRead,BufNewFile *.foo,*.bar,*.baz		setfiletype fooBarBaz
	au! BufRead,BufNewFile nginx.conf	setfiletype nginx
augroup END


" :autocmd FileType vim autocmd BufWritePost <buffer> call OnFileSave()
" Pre = onLoad , Post = afterSave
autocmd BufWritePre <buffer> :call OnFileSave()
autocmd BufWritePost <buffer> :call OnFileSave()


function! OnFileSave()
	let ext = &filetype
	let file_name = expand('%:t:r')
	let extension = expand('%:e')

	" Remove last word of each line ( %s/\s*\w\+\s*$// )
	" Remove last character of each line ( %s/.\{1}$// )
	if ext == 'vim'
		" Remove : from every first line
		silent! %s/^\s*://
		" silent! %s/^map/nnoremap/
		" silent! %s/^imap/inoremap/
		silent! %s/^nmap/nnoremap/
		silent! %s/^cmap/cnoremap/

	elseif extension == 'php'

		" Remove closing tag(?>) from every *.php file only TODO
		" PHP Performance (insted of " use ')
		" silent! %s/\"\([^"]*\)\"/'\1'/g
		" silent! %s/\s\+$//g
		silent! call PhpSortUse()
		silent! call PhpCsFixerFixFile()
	endif

	" Remove white space from all file type
	silent! %s/\s\+$//e

endfunction

command! FW call FilterToNewWindow('myscript')

function! FilterToNewWindow(script)
	let TempFile = tempname()
	let SaveModified = &modified
	exe 'w ' . TempFile
	let &modified = SaveModified
	exe 'split ' . TempFile
	exe '%! ' . a:script
endfunction
