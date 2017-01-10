set nocompatible
syntax on
set autoindent
set backspace=indent,eol,start
set cursorline
set display=lastline
set expandtab
set formatoptions+=j
set hidden
set ignorecase
set incsearch
set laststatus=2
set nojoinspaces
set nowrap
set number
set ruler
set scrolloff=5
set shiftround
set shiftwidth=4
set showcmd
set smartcase
set softtabstop=4
set tabstop=4
set ttimeout
set ttimeoutlen=50
set wildignorecase
set wildmenu
set wrap

nmap Y y$

cnoremap w!! w !sudo tee % > /dev/null

nnoremap gb <C-o>
nnoremap gf <C-i>

nnoremap j gj
nnoremap gj j
nnoremap k gk
nnoremap gk k

nnoremap [b :bprev<CR>
nnoremap ]b :bnext<CR>

nnoremap <silent> <Space> :nohlsearch<CR>

vnoremap < <gv
vnoremap > >gv

nnoremap <C-Left> <C-W><
nnoremap <C-Right> <C-W>>
nnoremap <C-Up> <C-W>+
nnoremap <C-Down> <C-W>-

nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k

command! -bang E e<bang>
command! -bang Q q<bang>
command! -bang W w<bang>
command! -bang Bd bd<bang>
command! -bang BD bd<bang>
command! -bang Qa qa<bang>
command! -bang QA qa<bang>
command! -bang Wa wa<bang>
command! -bang WA wa<bang>
command! -bang Wq wq<bang>
command! -bang WQ wq<bang>
