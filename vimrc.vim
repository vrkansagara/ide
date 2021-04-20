set runtimepath+=$HOME/.vim/src

function! VimErrorCaught()
	if v:exception != ""
		echo "\n" . 'Caught "' . v:exception . '" in ' . v:throwpoint ."\n"
	else
		echo 'Nothing caught\n'
	endif
endfunction

try
	"(Priority = 0) Initialization vim path loader
        if empty(glob('~/.vim/autoload/pathogen.vim'))
                silent !mkdir -p ~/.vim/autoload
                silent !curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
        endif

        "(Priority = 1) Initialization of vim
        source ~/.vim/basic.vim

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
