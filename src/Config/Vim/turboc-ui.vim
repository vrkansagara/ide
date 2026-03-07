" ==============================================================================
" File        : turboc-ui.vim
" Maintainer  : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
" Version     : 1.0.0
" Description : Turbo-C / Borland style UI — menu-bar hint tabline + statusline
" ==============================================================================

" ── Always show status + tab lines ───────────────────────────────────────────
set laststatus=2
set showtabline=2

" ── Ruler ────────────────────────────────────────────────────────────────────
set ruler

" ── Tabline: fake menu-bar showing Alt-key hints ─────────────────────────────
" Looks like classic IDE top bar:
"   [A-f]File  [A-e]Edit  [A-s]Search  [A-w]Window  [A-h]Help  [F10]Menu
function! TurboCTabline() abort
    let bar = ' [A-f]File  [A-e]Edit  [A-s]Search  [A-w]Window  [A-h]Help'
    let bar .= '  [F10]Open Menu  [A-p]Explorer  [C-p]Files  [C-f]Ripgrep '
    return bar
endfunction
set tabline=%!TurboCTabline()

" ── Mode label ───────────────────────────────────────────────────────────────
function! TurboCMode() abort
    let m = mode()
    if     m ==# 'n'        | return 'NORMAL'
    elseif m ==# 'i'        | return 'INSERT'
    elseif m ==# 'v'        | return 'VISUAL'
    elseif m ==# 'V'        | return 'V-LINE'
    elseif m ==# "\<C-v>"   | return 'V-BLOCK'
    elseif m ==# 'R'        | return 'REPLACE'
    elseif m ==# 'c'        | return 'COMMAND'
    elseif m ==# 't'        | return 'TERMINAL'
    else                    | return toupper(m)
    endif
endfunction

" ── Statusline: dark theme bottom bar ────────────────────────────────────────
set statusline=
set statusline+=\ %{TurboCMode()}\
set statusline+=\|\ %f                 " filename (relative)
set statusline+=%m                     " [+] if modified
set statusline+=%r                     " [RO] if read-only
set statusline+=%=                     " switch to right side
set statusline+=%y\                    " filetype [vim]
set statusline+=\|\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\ \|\ %l:%c
set statusline+=\ \|\ %p%%\
