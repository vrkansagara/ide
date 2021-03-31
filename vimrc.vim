set runtimepath+=$HOME/.vim/src

function! VimErrorCaught()
	if v:exception != ""
		echo "\n" . 'Caught "' . v:exception . '" in ' . v:throwpoint ."\n"
	else
		echo 'Nothing caught\n'
	endif
endfunction

try

	"(Priority = 1) Initialization of vim
	source ~/.vim/src/main.vim

	"(Priority = 2) VIM distributed plugin configuration override(load into 0-9,az,AZ order)
	for f in split(glob('~/.vim/src/Config/Plugin/*.vim'), '\n')
		if (filereadable(f))
			exe 'source' f
		else
			throw "File can not able to read " . f
		endif
	endfor

	"(Priority = 3) Override VIM built in functionality(load into 0-9,az,AZ order)
	for f in split(glob('~/.vim/src/Config/Vim/*.vim'), '\n')
		if (filereadable(f))
			exe 'source' f
		else
			throw "File can not able to read " . f
		endif
	endfor

	"(Priority = 4) Language specific settings configuration,Loading order that doesn't matter
	for f in split(glob('~/.vim/src/Config/Language/*.vim'), '\n')
		if (filereadable(f))
			exe 'source' f
		else
			throw "File can not able to read " . f
		endif
	endfor

	" Before passing access to user , it must be light background.
	echo "Do one thing and do it well - Vallabh Kansagara (VRKANSAGARA)."

catch /.*/
	call VimErrorCaught()
catch /^\d\+$/
	echo  "\n Error =========@START\n\n"
	echo "Caught error: " . v:exception
	echo "Caught error: " . v:errmsg
	echo  "\n Error =========@END\n"
finally
	" This is for fail back.
	" echo "Finally block called."
endtry
