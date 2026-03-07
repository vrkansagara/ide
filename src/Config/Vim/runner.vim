" ==============================================================================
" File        : runner.vim
" Maintainer  : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
" Version     : 1.1.0
" Description : Central filetype runner dispatcher.
"               Each language defines Run<ft>() in its own Config/Language file.
"               This file owns ALL Enter/<CR> key bindings — language files
"               must NOT map <C-m> / <CR> directly.
"
"   Enter      (normal mode) → Run<ft>()        — syntax check / compile / execute
"   Alt+R      (sh only)     → RunConfirmsh()   — ask then run (works in Guake/xterm)
"   F9         (sh only)     → RunConfirmsh()   — same, function-key fallback
"
"   NOTE: Shift+Enter cannot be distinguished from Enter in Guake/xterm terminals
"   because both send the same byte (\r). Use Alt+R or F9 for sh execution.
"
"   Adding a new filetype:
"     1. Define Run<ft>()             in src/Config/Language/<ft>.vim
"     2. Add autocmd line below       in the vk_runner augroup
"     3. Optionally define RunConfirm<ft>() and wire it to <A-r> / <F9>
" ==============================================================================

augroup vk_runner
    autocmd!

    " ── Enter → run / syntax-check ───────────────────────────────────────────
    autocmd FileType sh      nnoremap <buffer> <silent> <CR>   :call Runsh()<CR>
    autocmd FileType php     nnoremap <buffer> <silent> <CR>   :call Runphp()<CR>
    autocmd FileType go      nnoremap <buffer> <silent> <CR>   :call Rungo()<CR>
    autocmd FileType c       nnoremap <buffer> <silent> <CR>   :call Runc()<CR>
    autocmd FileType vim     nnoremap <buffer> <silent> <CR>   :call Runvim()<CR>
    autocmd FileType rust    nnoremap <buffer> <silent> <CR>   :call Runrust()<CR>
    autocmd FileType julia   nnoremap <buffer> <silent> <CR>   :call Runjulia()<CR>
    autocmd FileType make    nnoremap <buffer> <silent> <CR>   :call Runmake()<CR>
    autocmd FileType json    nnoremap <buffer> <silent> <CR>   :call Runjson()<CR>
    autocmd FileType html    nnoremap <buffer> <silent> <CR>   :call Runhtml()<CR>

    " ── Alt+R / F9 → run sh with confirmation ────────────────────────────────
    autocmd FileType sh      nnoremap <buffer> <silent> <A-r>  :call RunConfirmsh()<CR>
    autocmd FileType sh      nnoremap <buffer> <silent> <F9>   :call RunConfirmsh()<CR>

    " ── F5 → RefreshF5<ft>() — clean / lint / format buffer ─────────────────
    autocmd FileType sh      nnoremap <buffer> <silent> <F5>   :call RefreshF5sh()<CR>
    autocmd FileType php     nnoremap <buffer> <silent> <F5>   :call RefreshF5php()<CR>
    autocmd FileType go      nnoremap <buffer> <silent> <F5>   :call RefreshF5go()<CR>
    autocmd FileType c       nnoremap <buffer> <silent> <F5>   :call RefreshF5c()<CR>
    autocmd FileType vim     nnoremap <buffer> <silent> <F5>   :call RefreshF5vim()<CR>
    autocmd FileType rust    nnoremap <buffer> <silent> <F5>   :call RefreshF5rust()<CR>
    autocmd FileType julia   nnoremap <buffer> <silent> <F5>   :call RefreshF5julia()<CR>
    autocmd FileType make    nnoremap <buffer> <silent> <F5>   :call RefreshF5make()<CR>
    autocmd FileType json    nnoremap <buffer> <silent> <F5>   :call RefreshF5json()<CR>
    autocmd FileType html    nnoremap <buffer> <silent> <F5>   :call RefreshF5html()<CR>

augroup END
