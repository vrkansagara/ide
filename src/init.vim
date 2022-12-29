call plug#begin("$HOME/.vim/pack/vendor/start")
" call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

" Make sure you use single quotes

" NERD tree will be loaded on the first invocation of NERDTreeToggle command
" Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'preservim/nerdtree'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'yaegassy/coc-intelephense', {'do': 'yarn install --frozen-lockfile'}

" ColorScheme
Plug 'https://github.com/gosukiwi/vim-atom-dark.git'
Plug 'https://github.com/vim-scripts/peaksea.git'
Plug 'https://github.com/google/vim-colorscheme-primary.git'
Plug 'NLKNguyen/papercolor-theme'

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'https://github.com/tpope/vim-commentary.git'
Plug 'https://github.com/tpope/vim-surround.git'
Plug 'https://github.com/tpope/vim-fugitive.git'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'https://github.com/ctrlpvim/ctrlp.vim.git'
Plug 'https://github.com/mileszs/ack.vim.git'
Plug 'https://github.com/airblade/vim-gitgutter.git'
Plug 'https://github.com/vim-airline/vim-airline.git'
Plug 'https://github.com/vim-airline/vim-airline-themes.git'
Plug 'mattn/emmet-vim'
Plug 'https://github.com/tbknl/vimproject.git'

" Language specific 
Plug 'rust-lang/rust.vim'
Plug 'https://github.com/mattn/webapi-vim.git'

" Initialize plugin system
" - Automatically executes `filetype plugin indent on` and `syntax enable`.
call plug#helptags()
call plug#end()
" You can revert the settings after the call like so:
""   filetype indent off   " Disable file-type-specific indentation
""   syntax off            " Disable syntax highlighting