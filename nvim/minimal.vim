if has('vim_starting')
  let $VIMHOME = split(&runtimepath, ',')[0]
  if !has('nvim') " shitty but effective heuristic to determine whether this is a server
    " change cursor on different modes
    if exists("&t_SI")
      let &t_SI = "\<Esc>[5 q"
    endif
    if exists("&t_SR")
      let &t_SR = "\<Esc>[3 q"
    endif
    if exists("&t_EI")
      let &t_EI = "\<Esc>[2 q"
    endif
  endif

  " it's practically impossible to use vim without these
  let s:required_plugins = [
    \ 'nelstrom/vim-visual-star-search/master/plugin/visual-star-search.vim',
    \ 'tpope/vim-commentary/master/plugin/commentary.vim',
    \ 'tpope/vim-surround/master/plugin/surround.vim',
    \ 'tpope/vim-unimpaired/master/plugin/unimpaired.vim',
    \ ]
  for url in s:required_plugins
    let fname = fnamemodify(url, ':t')
    let locpath = $VIMHOME.'/plugin/'.fname
    if !filereadable(locpath)
      execute printf(
        \ '!curl -fLo %s --create-dirs https://raw.githubusercontent.com/%s',
        \ shellescape(locpath), url)
    endif
  endfor
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
if has('nvim')
  set inccommand=split
endif
set incsearch
set laststatus=2
set nojoinspaces
set nowrap
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

cnoremap <C-e> <End>
cnoremap <C-g> <C-c>
cnoremap <C-a> <Home>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <M-d> <S-Right><Right><C-w>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>
cnoremap <C-d> <Delete>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-k> <C-\>e getcmdpos() == 1 ? '' : getcmdline()[:getcmdpos()-2]<CR>

colorscheme default
hi! Search ctermfg=16 ctermbg=231 cterm=NONE
hi! Visual ctermfg=16 ctermbg=231 cterm=NONE

function! s:check_back_space() abort
  let l:col = col('.') - 1
  return !l:col || getline('.')[l:col - 1] !~? '\k'
endfunction

function! s:tab_completion(fwd) abort
  if pumvisible()
    return (a:fwd) ? "\<C-N>" : "\<C-P>"
  elseif !<SID>check_back_space()
    return "\<C-P>"
  endif
  return "\<Tab>"
endfunction

inoremap <expr> <silent> <Tab> <SID>tab_completion(1)
inoremap <expr> <silent> <S-Tab> <SID>tab_completion(0)

command! -bar StripTrailingWhitespace %s/\s\+$//e | nohlsearch
