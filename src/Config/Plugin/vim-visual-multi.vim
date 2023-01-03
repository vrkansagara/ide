"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
" Note       :- visual-multi
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Basic usage:
"     select words with Ctrl-N (like Ctrl-d in Sublime Text/VS Code)
"     create cursors vertically with Ctrl-Down/Ctrl-Up
"     select one character at a time with Shift-Arrows
"     press n/N to get next/previous occurrence
"     press [/] to select next/previous cursor
"     press q to skip current and get next occurrence
"     press Q to remove current cursor/selection
"     start insert mode with i,a,I,A

" Two main modes:
"     in cursor mode commands work as they would in normal mode
"     in extend mode commands work as they would in visual mode
"     press Tab to switch between «cursor» and «extend» mode

let g:VM_leader = ','

let g:VM_mouse_mappings   = 1
let g:VM_theme            = 'iceblue'

let g:VM_maps = {}
" let g:VM_maps["Redo"]     = '<C-r>'
let g:VM_maps["Undo"]     = 'u'

