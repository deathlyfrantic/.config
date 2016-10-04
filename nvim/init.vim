" --- startup processes --- {{{
let s:install_plugins = 0
if has('vim_starting')
  " stuff that should only have to happen once
  set encoding=utf-8
  " set termguicolors
  let $VIMHOME = split(&runtimepath, ',')[0]
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1

  " kill default vim plugins i don't want
  let g:loaded_vimballPlugin = "v35"
  let g:loaded_netrwPlugin = "v153"
  let g:loaded_tutor_mode_plugin = 1
  let g:loaded_2html_plugin = 'vim7.4_v1'

  " install vim-plug if it's not already - pluginless vim is terrible
  if !filereadable($VIMHOME.'/autoload/plug.vim')
    let s:install_plugins = 1
    execute '!curl -fLo '.$VIMHOME.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  endif

  " hide file cruft
  let &directory = $VIMHOME.'/swap'
  let &backupdir = $VIMHOME.'/backup'
  let &undodir = $VIMHOME.'/undo'
  let g:gutentags_cache_dir = $VIMHOME.'/tags'

  for dir in [&directory, &backupdir, &undodir, g:gutentags_cache_dir]
    if empty(glob(dir))
      silent! call mkdir(dir, 'p')
    endif
  endfor

  function! VimPlugUpdateRemotePlugins(...)
    UpdateRemotePlugins
  endfunction
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

" jsx {{{
let g:jsx_ext_required = 0
" }}}

" grepper {{{
nnoremap g/ :Grepper<CR>
nmap gs <Plug>(GrepperOperator)
xmap gs <Plug>(GrepperOperator)
" }}}

" gundo {{{
nnoremap <silent> gx :GundoToggle<CR>
let g:gundo_preview_bottom = 1
" }}}

" tagbar {{{
nnoremap <silent> gt :TagbarToggle<CR>
" }}}

" ultisnips {{{
let g:UltiSnipsExpandTrigger = '<C-k>'
let g:UltiSnipsJumpForwardTrigger = '<C-f>'
let g:UltiSnipsJumpBackwardTrigger = '<C-b>'
let g:UltiSnipsSnippetsDir = $VIMHOME.'/UltiSnips'
let g:snips_author = 'Zandr Martin'
" }}}

" sneak {{{
let g:sneak#use_ic_scs = 1
" }}}

" python syntax {{{
let g:python_highlight_all = 1
" }}}

" deoplete {{{
let g:deoplete#enable_at_startup = 1
let g:deoplete#auto_complete_start_length = 1
let g:deoplete#sources#clang#libclang_path = '/usr/lib/libclang.so'
let g:deoplete#sources#clang#clang_header = '/usr/lib/clang/'
" }}}

" ctrlp and ag stuff {{{
let g:ctrlp_open_multiple_files = '1jr'
if executable('ag')
  let s:ignore_string = join(map(copy(g:ignore_patterns), '"--ignore ''" . v:val . "''"'), ' ')
  let g:ctrlp_user_command = 'ag '.s:ignore_string.'%s -l --nocolor -g ""'
  let g:ctrlp_use_caching = 0
  let &grepprg="ag\ --nogroup\ --nocolor ".s:ignore_string
endif
" }}}

" tagbar {{{
let g:tagbar_autofocus = 1
let g:tagbar_iconchars = ['+', '-']
" }}}

" neomake {{{
let g:neomake_open_list = 2
let g:neomake_error_sign = {
  \ 'text': '!!',
  \ 'texthl': 'NeomakeErrorSign'
  \ }
let g:neomake_warning_sign = {
  \ 'text': '??',
  \ 'texthl': 'NeomakeWarningSign'
  \ }
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

" buftabline {{{
let g:buftabline_show = 1
let g:buftabline_indicators = 1
let g:buftabline_numbers = 2
nmap <silent> <M-1> :call BufferSwitch(0)<CR>
nmap <silent> <M-2> :call BufferSwitch(1)<CR>
nmap <silent> <M-3> :call BufferSwitch(2)<CR>
nmap <silent> <M-4> :call BufferSwitch(3)<CR>
nmap <silent> <M-5> :call BufferSwitch(4)<CR>
nmap <silent> <M-6> :call BufferSwitch(5)<CR>
nmap <silent> <M-7> :call BufferSwitch(6)<CR>
nmap <silent> <M-8> :call BufferSwitch(7)<CR>
nmap <silent> <M-9> :call BufferSwitch(8)<CR>
nmap <silent> <M-0> :call BufferSwitch(9)<CR>
nmap <silent> <M-q> :call BufferSwitch(10)<CR>
nmap <silent> <M-w> :call BufferSwitch(11)<CR>
nmap <silent> <M-e> :call BufferSwitch(12)<CR>
nmap <silent> <M-r> :call BufferSwitch(13)<CR>
nmap <silent> <M-t> :call BufferSwitch(14)<CR>
nmap <silent> <M-y> :call BufferSwitch(15)<CR>
nmap <silent> <M-u> :call BufferSwitch(16)<CR>
nmap <silent> <M-i> :call BufferSwitch(17)<CR>
nmap <silent> <M-o> :call BufferSwitch(18)<CR>
nmap <silent> <M-p> :call BufferSwitch(19)<CR>

function! BufferSwitch(buf_num)
  try
    let l:bn = buftabline#user_buffers()[a:buf_num]
    let l:cmd = 'b'.l:bn
    execute l:cmd
  catch
  endtry
endfunction
" }}}

" characterize {{{
nmap gA <Plug>(characterize)
" }}}

" easy-align {{{
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
" }}}
" --- end plugin settings --- }}}

" plugins --- {{{
call plug#begin($VIMHOME.'/plugged')
  " filetypes
  Plug 'mitsuhiko/vim-jinja',             {'for': ['htmljinja', 'jinja']}
  Plug 'StanAngeloff/php.vim',            {'for': 'php'}
  Plug 'hdima/python-syntax',             {'for': 'python'}
  Plug 'jeroenbourgois/vim-actionscript', {'for': 'actionscript'}
  Plug 'kchmck/vim-coffee-script',        {'for': 'coffee'}
  Plug 'rust-lang/rust.vim',              {'for': 'rust'}
  Plug 'pangloss/vim-javascript',         {'for': 'javascript'}
  Plug 'mxw/vim-jsx',                     {'for': 'javascript'}
  Plug 'justinmk/vim-syntax-extra',       {'for': 'c'}

  " text objects
  Plug 'Julian/vim-textobj-variable-segment'
  Plug 'justinmk/vim-sneak'
  Plug 'kana/vim-textobj-user'
  Plug 'michaeljsmith/vim-indent-object'
  Plug 'glts/vim-textobj-comment'

  " dev tools
  Plug 'SirVer/ultisnips'
  Plug 'airblade/vim-gitgutter'
  Plug 'honza/vim-snippets'
  Plug 'junegunn/gv.vim'
  Plug 'ludovicchabant/vim-gutentags'
  Plug 'mhinz/vim-grepper'
  Plug 'neomake/neomake'

  " deoplete
  Plug 'Shougo/deoplete.nvim', {'do':  function('VimPlugUpdateRemotePlugins')}
  Plug 'Shougo/neco-vim',      {'for': 'vim'}
  Plug 'Shougo/neco-syntax'
  Plug 'davidhalter/jedi',     {'for': 'python'}
  Plug 'zchee/deoplete-jedi',  {'for': 'python'}
  Plug 'zchee/deoplete-clang', {'for': 'c'}

  " panels
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'justinmk/vim-dirvish'
  Plug 'majutsushi/tagbar', {'on': 'TagbarToggle'}
  Plug 'sjl/gundo.vim',     {'on': 'GundoToggle'}

  " text manipulation
  Plug 'henrik/vim-indexed-search'
  Plug 'junegunn/vim-easy-align'
  Plug 'junegunn/vim-peekaboo'
  Plug 'nelstrom/vim-visual-star-search'
  Plug 'rstacruz/sparkup', {'for': keys(g:mta_filetypes)}
  Plug 'tommcdo/vim-exchange'

  " tpope's special section
  Plug 'tpope/vim-abolish'
  Plug 'tpope/vim-characterize'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-eunuch'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-scriptease'
  Plug 'tpope/vim-sleuth'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-unimpaired'

  " colors + vanity
  Plug 'Valloric/MatchTagAlways', {'for': keys(g:mta_filetypes)}
  Plug 'ap/vim-buftabline'
  Plug 'chrisbra/Colorizer',      {'on':  'ColorHighlight'}

  " my plugins
  for p in ['distill', 'textobj-blanklines']
    if isdirectory(expand('~/Code/vim/'.p))
      Plug '~/Code/vim/'.p
    else
      Plug 'zandrmartin/vim-'.p
    endif
  endfor
call plug#end()

" if necessary, install all the plugins before doing a bunch of plugin stuff,
" then quit because i'll have to restart anyway
if s:install_plugins
  PlugInstall
  UpdateRemotePlugins
  finish
  quit
endif
" --- end plugins --- }}}

" --- general settings --- {{{
set cinoptions+=(0
set colorcolumn=120
set completeopt-=preview
set cursorline
set expandtab
set fillchars=vert:\│,fold:-
set fileformats=unix,dos,mac
set foldlevel=99
set foldmethod=indent
set formatoptions-=c formatoptions+=jnroql
set hidden
set ignorecase
set lazyredraw
set listchars=space:·,eol:¬,tab:▸\ ,trail:☠,precedes:↪,extends:↩
set nojoinspaces
set nostartofline
set nowrap
set number
set shiftround
set showcmd
set smartcase
set spellfile=$VIMHOME/spell/custom.utf-8.add,$VIMHOME/spell/local.utf-8.add
set softtabstop=4
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

  " specify comment types for commentary
  autocmd FileType c,php setlocal commentstring=//%s
  autocmd FileType django,htmldjango,jinja,htmljinja setlocal commentstring={#%s#}

  " i will never be working with c++
  autocmd BufNewFile,BufReadPost *.c,*.h setlocal filetype=c

  " mutt and mail
  autocmd BufRead /tmp/mutt-* setlocal formatoptions-=o formatoptions-=r filetype=mail textwidth=72 spell | Wrap
  autocmd BufNewFile,BufReadPost *.muttrc setlocal filetype=muttrc

  " check all the things (except when quitting)
  autocmd BufWritePost * call <SID>neomake_check_on_write()
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

  " highlight `self`s for python
  autocmd FileType python syntax match pythonSelf "\<self\>"

  " markdown options. why does .md default to modula2 what even is that
  autocmd BufNewFile,BufReadPost *.md setlocal spell filetype=markdown textwidth=120 wrapmargin=0 | Wrap

  " strip trailing whitespace on most file-types
  autocmd BufWritePre *
    \ if index(['markdown', 'mail', 'snippets'], &ft) == -1 |
    \   %s/\s\+$//e |
    \ endif

  " xml options - makes xml folding very usable
  autocmd BufNewFile,BufReadPost *.xml
    \ let g:xml_syntax_folding = 1 |
    \ setlocal filetype=xml foldmethod=syntax foldcolumn=3

  " uglify js files on saving, if they aren't already
  autocmd BufWritePost *.js call <SID>uglify_js(expand('%:p'))

  " 'compile' sass files on saving, if they aren't _something.scss files
  autocmd BufWritePost *.scss
    \ if (executable('sass') || executable('sassc')) && expand('%:t')[0] != '_' |
    \   execute '!sass -t compressed '.expand('%:p').' '.expand('%:p:r').'.css' |
    \ endif

  " 'compile' coffeescript on saving
  autocmd BufWritePost *.coffee
    \ if executable('coffee') |
    \   execute '!coffee -c '.expand('%:p') |
    \ endif |
    \ call <SID>uglify_js(expand('%:p:r').'.js')

  " load fugitive on all buffers
  autocmd BufEnter * call fugitive#detect(getcwd())

  " i edit my vimrc enough i need autocmds dedicated to it #cooldude #sunglasses
  autocmd BufReadPost *.vim,$MYVIMRC setlocal foldmethod=marker
  autocmd BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END
" --- end autocommands --- }}}

" --- keymaps --- {{{
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
cnoremap !Make !make
cnoremap !MAke !make
cnoremap !MAKe !make
cnoremap !MAKE !make

" select last-pasted text
nnoremap gV `[v`]

" why isn't this default, idgaf about vi-compatibility
nmap Y y$

" sudo write
cnoremap w!! w !sudo tee % > /dev/null

" write then delete buffer; akin to wq
cnoremap wbd Wbd
command! -bang Wbd w<bang> | bd<bang>

" fix st key weirdness
map  <F1>  <Del>
map! <F1>  <Del>
imap <C-h> <BS>

" hide search highlighting
nnoremap <silent> <Space> :nohlsearch<CR>

" [G]o [B]ack and [G]o [F]orward - why are these C-o and C-i by default that makes no sense
nnoremap gb <C-o>
nnoremap gf <C-i>

" move in insert mode
inoremap <M-j> <Down>
inoremap <M-k> <Up>
inoremap <M-h> <Left>
inoremap <M-l> <Right>
inoremap <M-4> <End>
inoremap <M-6> <Home>

" resize windows
nnoremap <C-Left>  <C-W><
nnoremap <C-Right> <C-W>>
nnoremap <C-Up>    <C-W>+
nnoremap <C-Down>  <C-W>-

" switch windows
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k

" popup menu completion selection
inoremap <expr> <silent> <Tab>   pumvisible() ? '<C-N>' : '<Tab>'
inoremap <expr> <silent> <S-Tab> pumvisible() ? '<C-P>' : '<Tab>'

" strip trailing whitespace
command! StripTrailingWhitespace %s/\s\+$//e

" maintain visual mode for indenting
vnoremap < <gv
vnoremap > >gv

" more natural increment/decrement
nnoremap + <C-a>
nnoremap - <C-x>
vnoremap + <C-a>
vnoremap - <C-x>
vnoremap g+ g<C-a>
vnoremap g- g<C-x>

" i don't care that <C-c> and <Esc> are different
map! <C-c> <Esc>
xmap <C-c> <Esc>
" --- end keymaps --- }}}

" --- colors and appearance --- {{{
" colorscheme distill
set background=dark
colorscheme nihil
highlight User1 guifg=#ffffff guibg=#000000 ctermfg=231 ctermbg=16 gui=bold cterm=bold
highlight User2 guifg=#ff0000 guibg=#000000 ctermfg=196 ctermbg=16 gui=bold cterm=bold

command! Bright set background=light | colorscheme nihil
command! Dark   set background=dark  | colorscheme nihil

" statusline {{{
set statusline=\ %{strlen(fugitive#statusline())?fugitive#statusline().'\ ':''}
set statusline+=%<
set statusline+=%{fnamemodify(expand('%'),':~')}
set statusline+=\ %{&ft!=fnamemodify(expand('%'),':e')?'['.&ft.']\ ':''}
set statusline+=%{&ff!='unix'?'['.&ff.']\ ':''}
set statusline+=%{strlen(&fenc)&&&fenc!='utf-8'?'['.&fenc.']\ ':''}
set statusline+=%2*%{&ro?'\ \ read-only\ ':''}%*
set statusline+=%1*%{&mod?'\ \ modified\ ':''}%*
set statusline+=%=
set statusline+=%{&wrap?'\[wrap]\ ':''}
set statusline+=%c\ \|\ %l/%L\ \|\ %p%%%{'\ '}
" }}}
" --- end colors and appearance --- }}}

" --- miscellaneous --- {{{
" neomake check on write (but not quit)
function! s:neomake_check_on_write()
  if !exists('w:neomake_quitting') || !w:neomake_quitting
    Neomake
  endif
endfunction

" uglifyjs {{{
function! s:uglify_js(file)
  if executable('uglifyjs') && a:file !~? '.min.js'
    execute '!uglifyjs '.a:file.' -mo '.fnamemodify(a:file, ':r').'.min.'.fnamemodify(a:file, ':e')
  endif
endfunction
" }}}
" --- end miscellaneous functions --- }}}
