" ==============================================================================
" File        : vim-quickui.vim
" Maintainer  : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
" Version     : 3.0.0
" Description : vim-quickui Borland/Turbo-C style menu bar (dark theme)
" ==============================================================================

if exists('g:loaded_vim_quickui_config')
    finish
endif
let g:loaded_vim_quickui_config = v:true

" Borland style: classic double-line borders
let g:quickui_color_scheme = 'borland'
let g:quickui_border_style  = 2
let g:quickui_show_tip      = 1

" clear all the menus
call quickui#menu#reset()

" ── File ─────────────────────────────────────────────────────────────────────
call quickui#menu#install('&File', [
    \ [ '&New Tab\t:tabnew',         'tabnew',                             'Open a new tab'                ],
    \ [ '&Open...',                  'browse e .',                         'Open file browser'             ],
    \ [ '&Close\t:q',                'confirm q',                          'Close current window'          ],
    \ [ '--', '' ],
    \ [ '&Save\tCtrl+S',             'w',                                  'Write the current file'        ],
    \ [ 'Save &As...',               'browse w',                           'Write to a different name'     ],
    \ [ 'Save A&ll',                 'wa',                                 'Write all modified buffers'    ],
    \ [ '--', '' ],
    \ [ '&Recent Files\t:oldfiles',  'browse oldfiles',                    'Pick from recently opened files'],
    \ [ '--', '' ],
    \ [ 'E&xit\tAlt+X',              'confirm qa',                         'Quit Vim'                      ],
    \ ])

" ── Edit ─────────────────────────────────────────────────────────────────────
call quickui#menu#install('&Edit', [
    \ [ '&Undo\tu',                  'undo',                               'Undo last change'              ],
    \ [ '&Redo\tCtrl+R',             'redo',                               'Redo undone change'            ],
    \ [ '--', '' ],
    \ [ 'Cu&t',                      'normal! "+d',                        'Cut selection to clipboard'    ],
    \ [ '&Copy',                     'normal! "+y',                        'Copy selection to clipboard'   ],
    \ [ '&Paste',                    'normal! "+p',                        'Paste from clipboard'          ],
    \ [ '--', '' ],
    \ [ '&Select All',               'normal! ggVG',                       'Select entire buffer'          ],
    \ [ '--', '' ],
    \ [ 'Toggle Line &Numbers',      'set number!',                        'Show/hide line numbers'        ],
    \ [ 'Toggle &Wrap',              'set wrap!',                          'Toggle line wrapping'          ],
    \ [ 'Toggle S&yntax',            'if exists("g:syntax_on") | syntax off | else | syntax on | endif',
    \                                                                       'Toggle syntax highlighting'    ],
    \ [ '--', '' ],
    \ [ 'Trim &Whitespace\tF2',      'let _s=@/ | :%s/\s\+$//e | let @/=_s | nohl | retab',
    \                                                                       'Remove trailing whitespace'    ],
    \ ])

" ── Search ───────────────────────────────────────────────────────────────────
call quickui#menu#install('&Search', [
    \ [ '&Find...\t/',               'call feedkeys("/", "n")',             'Search forward'                ],
    \ [ 'Find &Prev\tN',             'normal! N',                          'Jump to previous match'        ],
    \ [ 'Find &Next\tn',             'normal! n',                          'Jump to next match'            ],
    \ [ '--', '' ],
    \ [ '&Replace in Line',          'call feedkeys(":s/", "n")',          'Substitute in current line'    ],
    \ [ 'Replace in &All\t:%s/',     'call feedkeys(":%s/", "n")',         'Substitute in whole file'      ],
    \ [ '--', '' ],
    \ [ '&Go to Line',               'call feedkeys(":". input("Go to line: ") . "\n", "n")',
    \                                                                       'Jump to line number'           ],
    \ [ 'Go to &Definition\tCtrl+]', 'exe "tag ". expand("<cword>")',      'Jump to tag definition'        ],
    \ [ '--', '' ],
    \ [ 'FZF &Files\tCtrl+P',        'Files',                              'Fuzzy find files (FZF)'        ],
    \ [ 'FZF &Lines\tCtrl+F',        'BLines',                             'Fuzzy find lines in buffer'    ],
    \ [ 'FZF &Git Files\tCtrl+G',    'GFiles',                             'Fuzzy find git-tracked files'  ],
    \ [ 'FZF &Buffer List',          'Buffers',                            'Fuzzy switch buffer'           ],
    \ [ 'FZF &Ripgrep',              'Rg',                                 'Ripgrep content search'        ],
    \ ])

" ── Window ───────────────────────────────────────────────────────────────────
call quickui#menu#install('&Window', [
    \ [ '&Split Horizontal',         'split',                              'Split window horizontally'     ],
    \ [ 'Split &Vertical',           'vsplit',                             'Split window vertically'       ],
    \ [ '--', '' ],
    \ [ 'Move &Left\tCtrl+H',        'wincmd h',                           'Move to left window'           ],
    \ [ 'Move &Down\tCtrl+J',        'wincmd j',                           'Move to window below'          ],
    \ [ 'Move &Up\tCtrl+K',          'wincmd k',                           'Move to window above'          ],
    \ [ 'Move &Right\tCtrl+L',       'wincmd l',                           'Move to right window'          ],
    \ [ '--', '' ],
    \ [ '&Next Tab\tgt',             'tabnext',                            'Switch to next tab'            ],
    \ [ '&Prev Tab\tgT',             'tabprevious',                        'Switch to previous tab'        ],
    \ [ '--', '' ],
    \ [ 'File &Explorer\tAlt+P',     'NERDTreeToggle',                     'Toggle NERDTree (right drawer)'],
    \ [ '&Terminal\tF12',            'call Terminal()',                     'Open popup terminal'           ],
    \ [ '--', '' ],
    \ [ 'Close &Others',             'only',                               'Close all other windows'       ],
    \ ])

" ── Help ─────────────────────────────────────────────────────────────────────
call quickui#menu#install('H&elp', [
    \ [ '&Cheat Sheet',              'help index',                         'Vim index of all commands'     ],
    \ [ '&Quick Reference',          'help quickref',                      'Quick reference card'          ],
    \ [ '&Tutorial',                 'help tutor',                         'Interactive tutorial'          ],
    \ [ '--', '' ],
    \ [ '&Version',                  'version',                            'Show Vim version info'         ],
    \ [ '--', '' ],
    \ [ '&About',
    \   'echo "Vim — Turbo-C style — vrkansagara"',                       'About this config'             ],
    \ ], 10000)

" ── Key bindings ─────────────────────────────────────────────────────────────
" Alt+letter opens the named menu directly (Borland IDE style)
nnoremap <silent> <A-f> :call quickui#menu#open('File')<cr>
nnoremap <silent> <A-e> :call quickui#menu#open('Edit')<cr>
nnoremap <silent> <A-s> :call quickui#menu#open('Search')<cr>
nnoremap <silent> <A-w> :call quickui#menu#open('Window')<cr>
nnoremap <silent> <A-h> :call quickui#menu#open('Help')<cr>

" F10 opens the full menu bar (classic IDE)
nnoremap <silent> <F10> :call quickui#menu#open()<cr>
