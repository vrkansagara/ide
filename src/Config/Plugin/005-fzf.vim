" ==============================================================================
" File        : 005-fzf.vim
" Maintainer  : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
" Version     : 3.0.0
" Description : fzf fuzzy finder — comprehensive key bindings
" ==============================================================================

if exists('g:loaded_fzf_config')
    finish
endif
let g:loaded_fzf_config = v:true

" ── FZF popup window style ───────────────────────────────────────────────────
let g:fzf_layout = { 'window': { 'width': 0.85, 'height': 0.75, 'border': 'rounded' } }

" Preview window (requires bat or cat)
let g:fzf_preview_window = ['right:50%', 'ctrl-/']

" ── File & Buffer search ─────────────────────────────────────────────────────
" Ctrl+P  — all files in project (replaces CtrlP)
nnoremap <silent> <C-p> :Files<CR>

" Ctrl+F  — file content search with ripgrep
nnoremap <silent> <C-f> :Rg<CR>

" Ctrl+G  — git-tracked files only
nnoremap <silent> <C-g> :GFiles<CR>

" Alt+b   — open buffers
nnoremap <silent> <A-b> :Buffers<CR>

" ── In-buffer line search ────────────────────────────────────────────────────
" <leader>/ — fuzzy lines in current buffer
nnoremap <silent> <leader>/ :BLines<CR>

" <leader>L — fuzzy lines across ALL open buffers
nnoremap <silent> <leader>L :Lines<CR>

" ── Git integration ──────────────────────────────────────────────────────────
" <leader>gc — git commits (browse & checkout)
nnoremap <silent> <leader>gc :Commits<CR>

" <leader>gbc — commits for current buffer only
nnoremap <silent> <leader>gbc :BCommits<CR>

" <leader>gs — git status files (changed/untracked)
nnoremap <silent> <leader>gs :GFiles?<CR>

" ── History search ───────────────────────────────────────────────────────────
" <leader>hf — recently opened files history
nnoremap <silent> <leader>hf :History<CR>

" <leader>h: — command-line history
nnoremap <silent> <leader>h: :History:<CR>

" <leader>h/ — search pattern history
nnoremap <silent> <leader>h/ :History/<CR>

" ── Tags & Help ──────────────────────────────────────────────────────────────
" <leader>tg — project tags (ctags)
nnoremap <silent> <leader>tg :Tags<CR>

" <leader>bt — buffer tags
nnoremap <silent> <leader>bt :BTags<CR>

" <leader>hh — vim help search
nnoremap <silent> <leader>hh :Helptags<CR>

" ── Misc ─────────────────────────────────────────────────────────────────────
" <leader>mk — marks
nnoremap <silent> <leader>mk :Marks<CR>

" <leader>mp — key mappings
nnoremap <silent> <leader>mp :Maps<CR>
