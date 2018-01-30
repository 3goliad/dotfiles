call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'

Plug 'dracula/vim'

Plug '/usr/share/vim/vimfiles/plugin/fzf'

Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'
Plug 'ervandew/supertab'
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
