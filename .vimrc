" Andrew's vimrc, made with only the best natural ingredients.


" ================= Plugin Options =================
" These options are for plugins, you can simply remove these
" if you don't want any plugins.

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
 set rtp+=~/.vim/bundle/Vundle.vim
 call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/vundle'
" ==== Language Addons ====
  "Plugin 'kchmck/vim-coffee-script'
  Plugin 'vhda/verilog_systemverilog.vim'

" ==== Plugins follow below ====
  Plugin 'scrooloose/nerdtree'
    map <C-n> :NERDTreeToggle<CR>
  "Plugin 'rking/ag.vim'
  "  let g:agprg="ag --column"
  "Bundle 'Valloric/YouCompleteMe'
  "Bundle 'bling/vim-airline'
  "Bundle 'tpope/vim-fugitive'
  Plugin 'kien/ctrlp.vim'
    let g:ctrlp_map = '<c-p>'
    let g:ctrlp_cmd = 'CtrlP'
    let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/]((\.(git|hg|svn))|bin|build|lib|node_modules)$',
      \ 'file': '\v\.(exe|so|dll)$',
      \ 'link': 'some_bad_symbolic_links',
      \ }
  "Bundle 'vim-scripts/taglist.vim'
    "nnoremap <silent> <F8> :TlistToggle<CR>
  "Plugin 'szw/vim-ctrlspace'
  Plugin 'scrooloose/syntastic'
    "set statusline+=%#warningmsg#
    "set statusline+=%{SyntasticStatuslineFlag()}
    "set statusline+=%*
    map <C-j> :SyntasticCheck<CR>
    map <C-h> :SyntasticReset<CR>
    "let g:syntastic_debug = 1
    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0
    " Java
    let g:syntastic_java_javac_delete_output = 1
    let g:syntastic_java_javac_config_file_enabled = 1
    " Coffeescript
    let g:syntastic_coffee_coffeelint_args = "--file ~/.vim/coffee-config.json"
    " C++/C
    "let g:syntastic_cpp_compiler = 'clang'
    "let g:syntastic_cpp_config_file = '.syntastic_cpp_config' " Actually default
    "Html
    let g:syntastic_html_tidy_exec = 'tidy5'
  Plugin 'racer-rust/vim-racer'
    let g:racer_cmd = "/home/andytl/.cargo/bin/racer"
    let g:racer_experimental_completer = 1
  Plugin 'rust-lang/rust.vim'
call vundle#end()
filetype plugin indent on

" ================= Vim Command line options =================
set wildmode=longest,list,full "Command line completion
  "set wildmenu "Alternative Command line completion
set showcmd "Show partial commands

" ================= Tab settings =================
set smartindent
set smarttab
set autoindent
set expandtab " Replaces tabs with spaces
set tabstop=2 " Spaces per tab
set shiftwidth=2
set laststatus=2
map <silent> <F6> :set noautoindent<CR>:set nosmarttab<CR>:set nosmartindent<CR>

" ================= Interface options =================
set backspace=indent,eol,start
set mouse=a "Allows clicking on screen
set confirm " Save dialog instead of error on :q
set ruler " Shows the current location of the cursor (ROW, COL) in the status bar
set list " Enable the previous
set cursorline " Highlight the current line where the cursor is located
set complete+=kspell " Word Completion
" Enable/disable the spellchecker with F8
map <silent> <F5> :setlocal spell! spelllang=en_us<CR>
" Enable relative line numbers while not in insert mode
"  au InsertEnter * :set nornu
"  au InsertLeave * :set rnu
"  set rnu


" ================= Search settings =================
set incsearch " Highlight matches while searching
set ignorecase " Ignore cases when searching
set smartcase " Case sensetive search if search string is not all lowercase
set magic " turn on regex special symbols

" ================= Whitespace Character settings =================
" Sample Tab characters ⇀▸⇁⇒⇝⇰⊳▹⟼➻
set listchars=tab:⇀\ ,trail:·,extends:#,nbsp:·

" ================= Code Folding settings =================
"set foldmethod=indent   " Fold based on indent
"set foldnestmax=10      " Deepest fold is 10 levels
"set nofoldenable        " Don't fold by default
"set foldlevel=1         " How far down to fold

" ================= Visual Settings =================
set number " Line numbers, trivial
syntax on " Get some color
set showmatch " Brace Matching
set nowrap " Disable wrapping lines because it gets annoying for small windows
set colorcolumn=80 "Show line 80 cutoff

" ================= Set color theme =================
let g:rehash256 = 1
color molokai

