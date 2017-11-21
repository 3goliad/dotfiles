call plug#begin('~/.local/share/nvim/site/plugged')
" Interface
Plug 'altercation/vim-colors-solarized'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-peekaboo'
Plug 'mhinz/vim-sayonara', { 'on': 'Sayonara' }
" Devtools
Plug 'neomake/neomake', { 'do': ':UpdateRemotePlugins'}
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins'}
" Plug 'Shougo/neosnippet.vim'| Plug 'Shougo/neosnippet-snippets'
" Plug 'SirVer/ultisnips'
" Editing
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'junegunn/vim-easy-align'
Plug 'vim-pandoc/vim-pandoc' | Plug 'vim-pandoc/vim-pandoc-syntax'
" Searching
Plug 'junegunn/vim-slash'
" Git
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'mhinz/vim-signify'
" Rust
Plug 'rust-lang/rust.vim'
Plug 'sebastianmarkow/deoplete-rust'
" Rust | Toml
Plug 'cespare/vim-toml' | Plug 'maralla/vim-toml-enhance'
" Ruby
Plug 'vim-ruby/vim-ruby'
" Haskell
Plug 'neovimhaskell/haskell-vim'
" Purescript
Plug 'raichoo/purescript-vim'
Plug 'frigoeu/psc-ide-vim'
" Javascript
Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }
Plug 'pangloss/vim-javascript'
Plug 'posva/vim-vue'
Plug 'mustache/vim-mustache-handlebars'
" Dockerfile
Plug 'honza/dockerfile.vim'
call plug#end()

colorscheme solarized
set background=dark
set textwidth=80
set autowrite
set showmatch
set smartcase
set wrapscan
set hidden
set noshowmode
set nu
set tabstop=2
set shiftwidth=2
set expandtab smarttab
set autoread
set nostartofline
set shada='1000,f1,<500,h,%
call matchadd('ColorColumn', '\%81v', 100)
" Use vim as pager
let $PAGER=''
" reload vimrc on save
autocmd BufWritePost $VIMRC source $VIMRC
" Binds
let mapleader="\<Space>"
let localleader="\<Space>"
nnoremap <Leader>j <PageDown>
nnoremap <Leader>k <PageUp>
nnoremap <Leader>l :Lines<CR>
nnoremap <Leader>o :GitFiles<CR>
nnoremap <Leader>O :GitFiles?<CR>
nnoremap <Leader>f :Files<CR>
nnoremap <Leader>n :cn<CR>
nnoremap <Leader>h :Helptags<CR>
nnoremap Q :Sayonara<CR>
nnoremap Y y$
nnoremap P $p
nnoremap <Leader><tab>   <c-w>w
nnoremap <Leader><S-tab> <c-w>W
" lightline
let g:lightline = {
			\ 'colorscheme': 'solarized',
			\ 'active': {
			\   'left': [ [ 'mode', 'paste' ],
			\             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
			\ },
			\ 'component_function': {
			\   'gitbranch': 'fugitive#head'
			\ },
			\ }
" peekaboo
let g:peekaboo_compact = 1
" Neomake
let g:neomake_open_list = 2
let g:neomake_list_height = 4
let g:neomake_error_sign = {'text': '‼', 'texthl': 'NeomakeErrorSign'}
let g:neomake_warning_sign = {
			\   'text': '⁈',
			\   'texthl': 'NeomakeWarningSign',
			\ }
let g:neomake_message_sign = {
			\   'text': 'ᵐ',
			\   'texthl': 'NeomakeMessageSign',
			\ }
let g:neomake_info_sign = {'text': 'ⁱ', 'texthl': 'NeomakeInfoSign'}
" Deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#ignore_sources = {}
let g:deoplete#omni#input_patterns = {}
let g:deoplete#omni#functions = {}
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
inoremap <expr><BS> deoplete#smart_close_popup()."\<BS>"
autocmd CompleteDone * silent! pclose!
" Javascript
let g:neomake_javascript_eslint_exe = 'npm'
let g:neomake_javascript_eslint_args = ['run', 'lint', '--silent', ' -- ']
let g:neomake_javascript_enabled_makers = ['eslint']
let g:deoplete#sources#ternjs#timeout = 1
" Rust
let g:rust_fold=1
let g:rustfmt_command='rustup run nightly rustfmt'
let g:deoplete#ignore_sources.rs=['buffer']
let g:deoplete#sources#rust#racer_binary='/home/javier/.cargo/bin/racer'
let g:deoplete#sources#rust#rust_source_path='/home/javier/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src/'
let g:neomake_rust_enabled_makers = ['cargo']
" Haskell
let g:haskell_enable_quantification = 1   " hl for `forall`
let g:haskell_enable_recursivedo = 1      " hl for `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " hl for `proc`
let g:haskell_enable_pattern_synonyms = 1 " hl for `pattern`
let g:haskell_enable_typeroles = 1        " hl for type roles
let g:haskell_enable_static_pointers = 1  " hl for `static`
let g:haskell_backpack = 1                " hl for backpack keywords
" Purescript
" let g:deoplete#omni#input_patterns.purescript = '[^\s\''"]+'
" Ripgrep
set grepprg=rg\ --vimgrep\ --no-heading
set grepformat=%f:%l:%c:%m,%f:%l:%m
command! -bang -nargs=* Rg call fzf#vim#grep(
			\ 'rg --column --no-heading --color=always '.shellescape(<q-args>), 1,
			\ <bang>0 ? fzf#vim#with_preview('up:60%')
			\         : fzf#vim#with_preview('right:50%:hidden', '?'),
			\ <bang>0)
