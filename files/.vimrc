" Andrew's vimrc, made with only the best natural ingredients.

"scriptencoding utf-8
set encoding=utf-8
" GVIM
if has("gui_running")
  if has("gui_gtk2")
    set guifont=Inconsolata\ 12
  elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h14
  elseif has("gui_win32")
    set guifont=DejaVu\ Sans\ Mono:h11:cANSI
  endif
endif
"cd c:\Users\andlam

" ================= Plugin Options =================
" These options are for plugins, you can simply remove these
" if you don't want any plugins.

set nocompatible              " be iMproved, required
set hidden
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/vundle'
  Plugin 'chikamichi/mediawiki.vim'
  Plugin 'digitaltoad/vim-jade'
" ==== Plugins follow below ====
"      Plugins are listed as Plugin <PluginName> followed by
"      configuration options for it.
  Plugin 'scrooloose/nerdtree'
    map <C-n> :NERDTreeToggle<CR>
" Plugin 'rking/ag.vim'
    "let g:agprg="ag --column"
" Plugin 'Valloric/YouCompleteMe'
" Plugin 'bling/vim-airline'
" Plugin 'tpope/vim-fugitive'
" Plugin 'tpope/vim-surround'
" Plugin 'tpope/vim-commentary'
  Plugin 'kien/ctrlp.vim'
    let g:ctrlp_map = '<c-p>'
    let g:ctrlp_cmd = 'CtrlP'
    let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/]((\.(git|hg|svn))|bin|build|lib|node_modules|obj|objd)$',
      \ 'file': '\v\.(exe|so|dll)$',
      \ 'link': 'some_bad_symbolic_links',
      \ }
" Plugin 'vim-scripts/taglist.vim'
"   nnoremap <silent> <F8> :TlistToggle<CR>
"  Plugin 'szw/vim-ctrlspace'
  Plugin 'scrooloose/syntastic'
    "map <C-b> :SyntasticCheck<CR>
    "map <C-h> :SyntasticReset<CR>
    let g:syntastic_java_javac_config_file_enabled = 1
    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 0
    let g:syntastic_check_on_open = 0
    let g:syntastic_check_on_wq = 0
    let g:syntastic_java_javac_delete_output = 1
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on

" ================= Vim Command line options =================
set wildmode=longest,list,full "Command line completion
  "set wildmenu "Alternative Command line completion
set showcmd "Show partial commands
set clipboard=unnamed

" ================= Tab settings =================
set smartindent
set smarttab
set autoindent
set expandtab " Replaces tabs with spaces
set tabstop=2 " Spaces per tab
set shiftwidth=2
set laststatus=2
map <silent> <F6> :set noautoindent<CR>:set nosmarttab<CR>:set nosmartindent<CR>
" Map the j & k keys to go down one row, this is useful for wrapped lines
noremap j gj
noremap k gk

" ================= Interface options =================
set backspace=indent,eol,start " Needed for vim on mac
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
set colorcolumn=80

" ================= Search settings =================
set incsearch " Highlight matches while searching
"set ignorecase " Ignore cases when searching
"set smartcase " Case sensetive search if search string is not all lowercase
set magic " turn on regex special symbols

" ================= Whitespace Character settings =================
" Sample Tab characters ⇀▸⇁⇒⇝⇰⊳▹⟼➻
" set listchars=trail:·,precedes:«,extends:»,eol:↲,tab:▸\ 
set listchars=trail:·,precedes:«,extends:»,eol:↲,tab:▸\
"set listchars=tab:▸,trail:.
",extends:-,nbsp:-\ 

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

" ================= Set color theme =================
let g:rehash256 = 1
" See .vim/colors
color monokai

" ================= User Keybinds =================

noremap $ lg$
map <C-h> mqgg0"+yG'qz.:echo 'Buffer copied to clipboard'<CR>
map <C-j> mqgg0"_dG"+P:echo 'Buffer replaced with clipboard'<CR>
"map <C-h> :echo 'Buffer copied to clipboard'<CR>
"map <C-j> :echo 'Buffer replaced with clipboard'<CR>
map <C-k> :source ~/_vimrc<CR>:echo 'Sourced vimrc'<CR>

noremap <A-:> $a;<ESC>

noremap <A-#> #/FROM<CR>w
noremap <A-*> *? =\><CR>b
