call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'

Plug 'dracula/vim'

Plug '/usr/share/vim/vimfiles/plugin/fzf'
Plug 'junegunn/fzf.vim'

Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'

Plug 'prettier/vim-prettier', { 'do': 'npm install' }
Plug 'pangloss/vim-javascript'
Plug 'leshill/vim-json'

Plug 'ervandew/supertab'

Plug 'tpope/vim-salve'
Plug 'tpope/vim-fireplace'
Plug 'vim-scripts/paredit.vim'
call plug#end()

colorscheme dracula
set background=dark
set textwidth=80
set autowrite
set showmatch
set smartcase
set hidden
set noshowmode
set nu
set tabstop=2
set shiftwidth=2
set expandtab

let mapleader="\<Space>"
let localleader="\<Space>"
nnoremap Y y$
nnoremap P $p
nnoremap <leader>fg :GFiles<CR>
