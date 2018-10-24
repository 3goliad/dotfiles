call plug#begin()
Plug 'tpope/vim-sensible'

Plug 'tpope/vim-surround'

Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'tpope/vim-eunuch'

Plug 'dracula/vim'
Plug 'itchyny/lightline.vim'

Plug 'ervandew/supertab'
Plug '/usr/share/vim/vimfiles/plugin/fzf'
Plug 'junegunn/fzf.vim'

Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'

Plug 'pangloss/vim-javascript'
Plug 'leshill/vim-json'
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
