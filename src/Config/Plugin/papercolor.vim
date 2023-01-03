let g:airline_theme='papercolor'
let g:lightline = { 'colorscheme': 'PaperColor' }
let g:PaperColor_Theme_Options = {
            \   'theme': {
            \     'default.dark': {
            \       'transparent_background': 0,
            \       'override' : {
            \         'color00' : ['#080808', '232'],
            \         'linenumber_bg' : ['#080808', '232']
            \       }
            \     },
            \     'default.light': {
            \       'transparent_background': 0,
            \       'override' : {
            \         'color00' : ['#080808', '232'],
            \         'linenumber_bg' : ['#080808', '232']
            \       }
            \     }
            \   },
            \   'language': {
            \     'python': {
            \       'highlight_builtins' : 1
            \     },
            \     'cpp': {
            \       'highlight_standard_library': 1
            \     },
            \     'c': {
            \       'highlight_builtins' : 1
            \     }
            \   }
            \ }