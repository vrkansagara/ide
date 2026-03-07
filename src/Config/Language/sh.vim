" ==============================================================================
" File        : sh.vim
" Maintainer  : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
" Version     : 2.0.0
" Description : Shell script filetype settings.
"               Enter key behaviour is owned by src/Config/Vim/runner.vim.
" ==============================================================================

" Treat *.sh as shell filetype
autocmd BufNewFile,BufRead *.sh set ft=sh

" Disable automatic comment continuation
autocmd FileType sh setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" NOTE: Do NOT map <C-m> / <CR> here — runner.vim owns those bindings.

" ------------------------------------------------------------------------------
" Runsh()   Called on Enter.  Syntax-checks the file WITHOUT executing it.
"           Uses system() instead of ! to avoid the "Press ENTER" re-trigger
"           loop.  Results are shown in a reusable scratch split at the bottom.
" ------------------------------------------------------------------------------
function! Runsh() abort
    let filePath = expand('%:p')
    let fileName = expand('%:t')

    execute 'silent! w!'

    if executable('shellcheck')
        let raw = system('shellcheck ' . shellescape(filePath) . ' 2>&1')
    else
        let raw = system('bash -n ' . shellescape(filePath) . ' 2>&1')
    endif
    let ok = (v:shell_error == 0)

    call s:ShowInScratch(fileName, ok, raw)
endfunction

" ------------------------------------------------------------------------------
" s:ShowInScratch()   Renders check output in a persistent bottom split.
"                     Re-uses an existing scratch window if one is open.
" ------------------------------------------------------------------------------
function! s:ShowInScratch(filename, ok, text) abort
    let title = '[ Shell Syntax: ' . a:filename . ' ]'

    " Re-use existing scratch or open a new one
    let win = bufwinnr('__sh_check__')
    if win == -1
        botright 12split
        enew
        setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
        setlocal nonumber norelativenumber nowrap
        file __sh_check__
    else
        execute win . 'wincmd w'
        setlocal modifiable
    endif

    silent! %delete _

    " Header
    call append(0, title)
    call append(1, repeat('─', len(title)))

    if a:ok
        call append(2, '✓  No syntax errors found.')
    else
        for line in split(a:text, "\n")
            call append(line('$'), line)
        endfor
        call append(line('$'), '')
        call append(line('$'), '✗  Fix the errors above and press Enter again.')
    endif

    setlocal nomodifiable
    " Stay in the scratch window so user can read, or jump back with Ctrl+W p
    normal! gg
endfunction

" ------------------------------------------------------------------------------
" RunConfirmsh()   Called on Shift+Enter / F9.
"                  Asks for confirmation, then executes the script with bash.
" ------------------------------------------------------------------------------
function! RunConfirmsh() abort
    let filePath = expand('%:p')
    let fileName = expand('%:t')

    " Save first so we always run the latest version
    execute 'silent! w!'

    let answer = input('Run ' . fileName . '? [y/N]: ')
    redraw
    if answer !~? '^y'
        echo 'Cancelled.'
        return
    endif

    " Use a terminal split so output streams live and no "Press ENTER" loop
    execute 'botright 20split'
    execute 'terminal bash ' . shellescape(filePath)
endfunction

" ------------------------------------------------------------------------------
" RefreshF5sh()   Called on F5 — cleans up the buffer.
" ------------------------------------------------------------------------------
function! RefreshF5sh() abort
    " Trim trailing whitespace (F2)
    execute "normal \<F2>"
    " Re-indent whole file
    execute 'normal gg=G``'
endfunction
