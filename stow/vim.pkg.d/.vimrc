call plug#begin()
Plug 'tpope/vim-sensible'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'

Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'tpope/vim-eunuch'

Plug 'dracula/vim'
Plug 'itchyny/lightline.vim'

Plug 'ervandew/supertab'
Plug '/usr/share/vim/vimfiles/plugin/fzf'
Plug 'junegunn/fzf.vim'

Plug 'w0rp/ale'

Plug 'janko-m/vim-test'

" Rust
Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'

" Javascript
Plug 'pangloss/vim-javascript'
Plug 'leshill/vim-json'

" Python
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'vim-python/python-syntax'
Plug 'davidhalter/jedi-vim'
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

" Indenting
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

let g:lightline = {
  \ 'colorscheme': 'dracula',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
  \ },
  \ 'component_function': {
  \   'gitbranch': 'fugitive#head'
  \ },
  \ }

let mapleader="\<Space>"
let localleader="\<Space>"
nnoremap Y y$
nnoremap P $p
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>ff :Files<CR>
nnoremap <leader>bb :Buffers<CR>
nnoremap <leader>bs :w<CR>

" test.vim
let test#strategy = "vimterminal"

" Ale
let g:ale_linters = { 'python': ['pylint'], 'ruby': ['standardrb'], 'asm': [] }
let g:ale_fixers = { 'ruby': ['standardrb'] }
nnoremap <leader>cf :ALEFix<CR>

" Python
autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
let g:ale_python_auto_pipenv = 1
let g:python_highlight_all = 1

" Vim Terminal
autocmd TerminalOpen * setlocal nonumber norelativenumber

" Ruby
augroup thor_ft
  au!
  autocmd BufNewFile,BufRead *.thor set filetype=ruby
augroup END
