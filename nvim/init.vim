" --- startup processes --- {{{
if has('vim_starting')
  " stuff that should only have to happen once
  set encoding=utf-8
  let $VIMHOME = split(&runtimepath, ',')[0]

  if $TERM != 'linux' && has('nvim')
    set termguicolors
    set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
  endif

  " set sensible defaults for regular vim
  if !has('nvim')
    source $VIMHOME/minimal.vim
  endif

  " kill default vim plugins i don't want
  let g:loaded_vimballPlugin = 'v35'
  let g:loaded_netrwPlugin = 'v153'
  let g:loaded_tutor_mode_plugin = 1
  let g:loaded_2html_plugin = 'vim7.4_v1'

  " install vim-plug if it's not already
  if !filereadable($VIMHOME.'/autoload/plug.vim')
    execute '!curl -fLo '.$VIMHOME.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall | UpdateRemotePlugins | source $MYVIMRC
  endif

  " hide file cruft
  let &directory = $VIMHOME.'/swap'
  let &backupdir = $VIMHOME.'/backup'
  let &undodir   = $VIMHOME.'/undo'
  let g:gutentags_cache_dir = $XDG_CACHE_HOME.'/tags'

  for dir in [&directory, &backupdir, &undodir, g:gutentags_cache_dir]
    if empty(glob(dir))
      silent! call mkdir(dir, 'p')
    endif
  endfor
endif
" --- end startup --- }}}

" --- plugin settings --- {{{
" ignore patterns - used in a couple places {{{
let g:ignore_patterns = [
  \ '__pycache__/',
  \ '__pycache__',
  \ '.git',
  \ '.gitmodules',
  \ '*.pyc',
  \ '*.swp',
  \ '*.min.js',
  \ '*.sql',
  \ '*.sqlite3',
  \ '.sass-cache',
  \ ]
" }}}

" grepper {{{
nnoremap g/ :Grepper<CR>
nmap gs <Plug>(GrepperOperator)
xmap gs <Plug>(GrepperOperator)
" }}}

" gundo {{{
nnoremap <silent> <C-q> :GundoToggle<CR>
let g:gundo_preview_bottom = 1
" }}}

" tagbar {{{
nnoremap <silent> <C-t> :TagbarToggle<CR>
" }}}

" ultisnips {{{
let g:UltiSnipsExpandTrigger = '<C-]>'
let g:UltiSnipsJumpForwardTrigger = '<C-f>'
let g:UltiSnipsJumpBackwardTrigger = '<C-b>'
let g:UltiSnipsSnippetsDir = $VIMHOME.'/UltiSnips'
let g:ultisnips_python_quoting_style = 'single'
let g:ultisnips_python_triple_quoting_style = 'double'
let g:snips_author = 'Zandr Martin'
" }}}

" sneak {{{
let g:sneak#use_ic_scs = 1
" }}}

" ctrlp and ag stuff {{{
let g:ctrlp_open_multiple_files = '1jr'
if executable('ag')
  let s:ignore_string = join(map(copy(g:ignore_patterns), '"--ignore ''" . v:val . "''"'), ' ')
  let g:ctrlp_user_command = 'ag '.s:ignore_string.'%s -l --nocolor -g ""'
  let g:ctrlp_use_caching = 0
  let &grepprg='ag --nogroup --nocolor '.s:ignore_string
endif
" }}}

" tagbar {{{
let g:tagbar_autofocus = 1
let g:tagbar_iconchars = ['+', '-']
" }}}

" neomake {{{
let g:neomake_open_list = 2
let g:neomake_list_height = 5
let g:neomake_error_sign = {'text': '!!', 'texthl': 'NeomakeErrorSign'}
let g:neomake_warning_sign = {'text': '??', 'texthl': 'NeomakeWarningSign'}
" }}}

" match tag always settings - doubles as list of xml/html types {{{
let g:mta_filetypes = {
  \ 'html': 1,
  \ 'xhtml': 1,
  \ 'xml': 1,
  \ 'jinja': 1,
  \ 'htmljinja': 1,
  \ 'htmldjango': 1,
  \ }
" }}}

" sparkup {{{
let g:sparkupExecuteMapping = '<C-^>'
let g:sparkupNextMapping = '<C-f>'
let g:sparkupFiletypes = keys(g:mta_filetypes)
" }}}

" buftabline {{{
let g:buftabline_show = 1
let g:buftabline_indicators = 1
let g:buftabline_numbers = 2
" }}}

" lion {{{
let g:lion_squeeze_spaces = 1
" }}}
" --- end plugin settings --- }}}

" --- plugins --- {{{
call plug#begin($VIMHOME.'/plugged')
  " filetypes
  Plug 'Vimjas/vim-python-pep8-indent', {'for': 'python'}
  Plug 'Kareeeeem/python-docstring-comments', {'for': 'python'}
  Plug 'mitsuhiko/vim-jinja', {'for': ['htmljinja', 'jinja']}
  Plug 'pangloss/vim-javascript', {'for': 'javascript'}

  " text objects
  Plug 'Julian/vim-textobj-variable-segment'
  Plug 'justinmk/vim-sneak'
  Plug 'kana/vim-textobj-user'
  Plug 'michaeljsmith/vim-indent-object'
  Plug 'glts/vim-textobj-comment'
  Plug 'zandrmartin/vim-textobj-blanklines'

  " dev tools
  Plug 'SirVer/ultisnips'
  Plug 'airblade/vim-gitgutter'
  Plug 'honza/vim-snippets'
  Plug 'junegunn/gv.vim'
  Plug 'ludovicchabant/vim-gutentags'
  Plug 'mhinz/vim-grepper'
  Plug 'neomake/neomake'
  Plug 'sjl/strftimedammit.vim'

  " panels
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'justinmk/vim-dirvish'
  Plug 'majutsushi/tagbar', {'on': 'TagbarToggle'}
  Plug 'sjl/gundo.vim', {'on': 'GundoToggle'}
  Plug 'ap/vim-buftabline'

  " text manipulation
  Plug 'Valloric/MatchTagAlways', {'for': keys(g:mta_filetypes)}
  Plug 'dhruvasagar/vim-table-mode', {'on': 'TableModeEnable'}
  Plug 'henrik/vim-indexed-search'
  Plug 'junegunn/vim-peekaboo'
  Plug 'nelstrom/vim-visual-star-search'
  Plug 'tommcdo/vim-exchange'
  Plug 'tommcdo/vim-lion'
  Plug 'zandrmartin/vim-sparkup/'

  " tpope's special section
  Plug 'tpope/vim-abolish'
  Plug 'tpope/vim-characterize'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-endwise'
  Plug 'tpope/vim-eunuch'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-scriptease'
  Plug 'tpope/vim-sleuth'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-unimpaired'
call plug#end()
" --- end plugins --- }}}

" --- general settings --- {{{
set cinoptions+=:0,(0
set colorcolumn=+1
" set colorcolumn=121
set complete+=i,d,kspell
set completeopt-=preview
set completefunc=completion#snippet
set cursorline
set expandtab
set fillchars=vert:\│,fold:-
set fileformats=unix,dos,mac
set foldlevel=99
set foldmethod=indent
set formatoptions+=jnroql
set gdefault
set hidden
set ignorecase
set inccommand=split
set lazyredraw
set listchars=space:·,eol:¬,tab:▸\ ,trail:·,precedes:↪,extends:↩
set mouse=
set nojoinspaces
set nostartofline
set nowrap
set number
set shiftround
set shiftwidth=4
set sidescroll=1
set showcmd
set smartcase
set spellfile=$VIMHOME/spell/custom.utf-8.add,$VIMHOME/spell/local.utf-8.add
set softtabstop=4
set synmaxcol=500
set textwidth=80
set title
set ttimeout
set ttimeoutlen=50
set undofile
let &wildignore=join(g:ignore_patterns, ',')
set wildignorecase
set writebackup
" --- end general --- }}}

" --- autocommands --- {{{
augroup rc_commands
  autocmd!

  " omni-complete
  autocmd FileType * if &omnifunc == '' | set omnifunc=syntaxcomplete#Complete | endif

  " specify comment types for commentary
  autocmd FileType c,php setlocal commentstring=//%s
  autocmd FileType django,htmldjango,jinja,htmljinja setlocal commentstring={#%s#}
  autocmd FileType cmake setlocal commentstring=#%s

  " i will never be working with c++
  autocmd BufNewFile,BufReadPost *.c,*.h setlocal filetype=c

  " mutt and mail
  autocmd BufRead /tmp/mutt-* setlocal filetype=mail
  autocmd BufNewFile,BufReadPost *.muttrc setlocal filetype=muttrc

  " check all the things (except when quitting)
  autocmd BufWritePost *
    \ if !exists('w:neomake_quitting') || !w:neomake_quitting |
    \   Neomake |
    \ endif
  autocmd QuitPre * let w:neomake_quitting = 1

  " quit even if dirvish or quickfix is open
  autocmd BufEnter *
    \ if winnr('$') == 1 && (&buftype ==? 'quickfix' || &buftype ==? 'nofile') |
    \   if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1 |
    \     quit |
    \   else |
    \     bd! |
    \   endif |
    \ endif

  " see :help last-position-jump
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   execute "normal! g`\"zvzz" |
    \ endif

  " don't move my position when switching buffers
  autocmd! BufWinLeave * let b:winview = winsaveview()
  autocmd! BufWinEnter * if exists('b:winview') | call winrestview(b:winview) | unlet b:winview

  " strip trailing whitespace on most file-types
  autocmd BufWritePre *
    \ if index(['mail', 'snippets', 'conf'], &ft) == -1 |
    \   %s/\s\+$//e |
    \ endif

  " 'compile' sass files on saving, if they aren't _something.scss files
  autocmd BufWritePost *.scss
    \ if (executable('sass') || executable('sassc')) && expand('%:t')[0] != '_' |
    \   execute '!sass -t compressed '.expand('%:p').' '.expand('%:p:r').'.css' |
    \ endif

  " load fugitive on all buffers
  autocmd BufEnter * call fugitive#detect(getcwd())

  " i edit my vimrc enough i need autocmds dedicated to it #cooldude #sunglasses
  autocmd BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END
" --- end autocommands --- }}}

" --- keymaps and commands --- {{{
" typos
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

" select last-pasted text
nnoremap gV `[v`]

" turns out i do not need an escape key
inoremap jk <Esc>

" why isn't this default, idgaf about vi-compatibility
nmap Y y$

" sudo write
cnoremap w!! w !sudo tee % > /dev/null

" current directory in command-line
cnoremap <expr> %% fnameescape(expand('%:p:h')).'/'

" command-line up/down
cnoremap <C-k> <Up>
cnoremap <C-j> <Down>

" write then delete buffer; akin to wq
cnoremap wbd Wbd
command! -bang Wbd w<bang> | bd<bang>

" hide search highlighting
nnoremap <silent> <Space> :nohlsearch<CR>

" resize windows
nnoremap <C-Left>  <C-W><
nnoremap <C-Right> <C-W>>
nnoremap <C-Up>  <C-W>+
nnoremap <C-Down>  <C-W>-

" switch windows
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
if $TERM !~? "termite"
  " fix for gnome terminal and its shitty xterm-256color terminfo
  nnoremap <BS> <C-W>h
endif

" switch buffers
nnoremap <silent> <M-h> :bprev<CR>
nnoremap <silent> <M-l> :bnext<CR>

" strip trailing whitespace
command! StripTrailingWhitespace %s/\s\+$//e | nohlsearch

" un-dos files with ^M line endings
command! Undos e ++ff=unix | %s///g

" maintain visual mode for indenting
vnoremap < <gv
vnoremap > >gv

" maintain visual mode for increment/decrement
vnoremap <C-a> <C-a>gv
vnoremap <C-x> <C-x>gv

" completion
inoremap <expr> <silent> <Tab> completion#tab(1)
inoremap <expr> <silent> <S-Tab> completion#tab(0)

" external file processing
command! -nargs=? UglifyJS call utils#uglify_js(<args>)
command! -nargs=? DotToPng call utils#dot_to_png(<args>)
" --- end keymaps --- }}}

" --- colors and appearance --- {{{
" colors {{{
set background=dark
if $TERM == 'linux'
  colorscheme default
elseif strftime('%H') > 21 || strftime('%H') < 6
  colorscheme nihil
else
  colorscheme mastodon
endif
" }}}

" statusline {{{
set statusline=%{strlen(fugitive#statusline())?fugitive#statusline().'\ ':''}
set statusline+=%<%F
set statusline+=%{&ff!='unix'?'\ \ ['.&ff.']':''}
set statusline+=%{strlen(&fenc)&&&fenc!='utf-8'?'\ \ ['.&fenc.']':''}
set statusline+=\ %h%m%r%=
set statusline+=%{&wrap?'\[wrap]\ ':''}
set statusline+=%c%V\ \|\ %l/%L\ \|\ %p%%
" }}}
" --- end colors and appearance --- }}}
