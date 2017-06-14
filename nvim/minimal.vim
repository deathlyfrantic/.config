if has('vim_starting')
    let $VIMHOME = split(&runtimepath, ',')[0]
    if !has('nvim') " shitty but effective heuristic to determine whether this is a server
        " change cursor on different modes
        let &t_SI = "\<Esc>[5 q"
        let &t_SR = "\<Esc>[3 q"
        let &t_EI = "\<Esc>[2 q"

        " it's practically impossible to use vim without these
        let s:required_plugins = [
            \ 'https://raw.githubusercontent.com/nelstrom/vim-visual-star-search/master/plugin/visual-star-search.vim',
            \ 'https://raw.githubusercontent.com/tpope/vim-commentary/master/plugin/commentary.vim',
            \ 'https://raw.githubusercontent.com/tpope/vim-surround/master/plugin/surround.vim',
            \ 'https://raw.githubusercontent.com/tpope/vim-unimpaired/master/plugin/unimpaired.vim'
            \ ]
        for url in s:required_plugins
            let fname = fnamemodify(url, ':t')
            let locpath = $VIMHOME.'/plugin/'.fname
            if !filereadable(locpath)
                execute '!curl -fLo '.locpath.' --create-dirs '.url
            endif
        endfor
    endif
endif

set nocompatible
syntax on
set autoindent
set backspace=indent,eol,start
set cursorline
set display=lastline
set expandtab
set formatoptions+=j
set hidden
set hlsearch
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

inoremap jk <Esc>

cnoremap w!! w !sudo tee % > /dev/null

nnoremap j gj
nnoremap gj j
nnoremap k gk
nnoremap gk k

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

colorscheme default
hi! Search ctermfg=16 ctermbg=231 cterm=NONE
hi! Visual ctermfg=16 ctermbg=231 cterm=NONE
