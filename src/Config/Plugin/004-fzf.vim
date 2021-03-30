

" Most commands support CTRL-T / CTRL-X / CTRL-V key bindings to open in a new tab, a new split, or in a new vertical split
" Bang-versions of the commands (e.g. Ag!) will open fzf in fullscreen
" You can set g:fzf_command_prefix to give the same prefix to the commands
" e.g. let g:fzf_command_prefix = 'Fzf' and you have FzfFiles, etc.

" FZF window will take almost full screen
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.9 } }

" changes file preview window to take 60% of the FZF window, will place
" search bar on top with a bit of margin, will also color the preview
" using the Bat CLI app (it's an alternative to Cat(0) which uses
" syntax highlighting and allows using themes, like Dracula, from
" the Brazilian developer, @Zenorocha. To use one of the themes,
" it's advised to set the env var BAT_THEME into your profile
" file - i.e, ~/.zshrc - to the name of theme you want to use
" and Bat allows to use)
let $FZF_DEFAULT_OPTS="--ansi --preview-window 'right:60%' --layout reverse --margin=1,4 --preview 'bat --color=always --style=header,grid --line-range :300 {}'"


" FZF modal window layout and extra info
" uses <CTRL>+P to fuzzy search in normal mode
nmap <silent> <C-p> :Files<CR>


" Quickly find and open a buffer
nnoremap <leader>b :Buffers<cr>
nnoremap <leader>o :Buffers<cr>

nnoremap <leader>. :Tags<cr>
nnoremap <leader>` :History<cr>

