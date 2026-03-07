" ==============================================================================
" File        : runner.vim
" Maintainer  : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
" Version     : 1.0.0
" Description : Central filetype runner dispatcher.
"               Each language defines Run<ft>() in its own Config/Language file.
"               This file owns ALL Enter/<CR> key bindings — language files
"               must NOT map <C-m> / <CR> directly.
"
"   Enter (normal mode)       → Run<ft>() — syntax check, compile, or execute
"   Shift+Enter (sh only)     → RunConfirm<ft>() — ask before executing
"   F9  (sh fallback)         → same as Shift+Enter (for terminals without S-CR)
"
"   Adding a new filetype:
"     1. Define Run<ft>()         in src/Config/Language/<ft>.vim
"     2. Add autocmd line below   in the vk_runner augroup
"     3. Optionally define RunConfirm<ft>() for Shift+Enter support
" ==============================================================================

augroup vk_runner
    autocmd!

    " ── Enter → filetype action ───────────────────────────────────────────────
    " sh: syntax check (NOT execute) — see Runsh() in Language/sh.vim
    autocmd FileType sh      nnoremap <buffer> <silent> <CR>   :call Runsh()<CR>

    " php: execute with php CLI — see Runphp() in Language/php.vim
    autocmd FileType php     nnoremap <buffer> <silent> <CR>   :call Runphp()<CR>

    " Other supported filetypes
    autocmd FileType go      nnoremap <buffer> <silent> <CR>   :call Rungo()<CR>
    autocmd FileType c       nnoremap <buffer> <silent> <CR>   :call Runc()<CR>
    autocmd FileType vim     nnoremap <buffer> <silent> <CR>   :call Runvim()<CR>
    autocmd FileType rust    nnoremap <buffer> <silent> <CR>   :call Runrust()<CR>
    autocmd FileType julia   nnoremap <buffer> <silent> <CR>   :call Runjulia()<CR>
    autocmd FileType make    nnoremap <buffer> <silent> <CR>   :call Runmake()<CR>
    autocmd FileType json    nnoremap <buffer> <silent> <CR>   :call Runjson()<CR>
    autocmd FileType html    nnoremap <buffer> <silent> <CR>   :call Runhtml()<CR>

    " ── Shift+Enter → confirm-then-run (sh only; others same as Enter) ────────
    " NOTE: requires a terminal that sends a distinct escape for Shift+Enter
    " (e.g. Kitty, WezTerm, Alacritty with CSI-u protocol).
    " For st/xterm, use F9 as the reliable fallback instead.
    autocmd FileType sh      nnoremap <buffer> <silent> <S-CR> :call RunConfirmsh()<CR>

    " ── F9 → reliable fallback for sh "run with confirmation" ────────────────
    autocmd FileType sh      nnoremap <buffer> <silent> <F9>   :call RunConfirmsh()<CR>

augroup END
