" --- startup processes --- {{{
if has('vim_starting')
  " stuff that should only have to happen once
  let $VIMHOME = split(&runtimepath, ',')[0]

  if $TERM != 'linux' && exists('+termguicolors')
    set termguicolors
  endif

  " kill default vim plugins i don't want
  let g:loaded_vimballPlugin = 'v35'
  let g:loaded_netrwPlugin = 'v153'
  let g:loaded_tutor_mode_plugin = 1
  let g:loaded_2html_plugin = 'vim7.4_v1'

  " install vim-plug if it's not already
  let s:plug_path = printf('%s/autoload/plug.vim', $VIMHOME)
  if !filereadable(s:plug_path)
    execute printf('!curl -fLo %s --create-dirs', s:plug_path)
      \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall
    autocmd VimEnter * UpdateRemotePlugins
    autocmd VimEnter * nested source $MYVIMRC
  endif
  unlet s:plug_path
endif
" --- end startup --- }}}

" --- general settings --- {{{
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
  \ '.DS_Store',
  \ 'node_modules',
  \ 'node_modules/',
  \ 'package-lock.json',
  \ ]
" }}}

set cinoptions+=:0,(0
set colorcolumn=+1
set complete+=i,d,kspell
set completeopt-=preview
set completeopt+=longest
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
set textwidth=80
set title
set ttimeout
set ttimeoutlen=50
set undofile
let &wildignore=join(g:ignore_patterns, ',')
set wildignorecase
set writebackup
" --- end general settings --- }}}

" --- plugins --- {{{
call plug#begin(printf('%s/plugged', $VIMHOME))
" filetypes {{{
Plug 'Vimjas/vim-python-pep8-indent', {'for': 'python'}
Plug 'Kareeeeem/python-docstring-comments', {'for': 'python'}
Plug 'mitsuhiko/vim-jinja', {'for': ['htmljinja', 'jinja']}
Plug 'pangloss/vim-javascript', {'for': 'javascript'}

Plug 'mxw/vim-jsx', {'for': 'javascript'}
let g:jsx_ext_required = 0
" }}}

" text objects {{{
Plug 'Julian/vim-textobj-variable-segment'
Plug 'kana/vim-textobj-user'
Plug 'michaeljsmith/vim-indent-object'
Plug 'glts/vim-textobj-comment'
Plug 'zandrmartin/vim-textobj-blanklines'

Plug 'justinmk/vim-sneak'
let g:sneak#use_ic_scs = 1
" }}}

" dev tools {{{
Plug 'sjl/strftimedammit.vim'
Plug 'junegunn/gv.vim', {'on': 'GV'}

Plug 'ludovicchabant/vim-gutentags'
let g:gutentags_cache_dir = printf('%s/tags', $XDG_CACHE_HOME)

Plug 'SirVer/ultisnips'
let g:UltiSnipsExpandTrigger = '<C-]>'
let g:UltiSnipsJumpForwardTrigger = '<C-f>'
let g:UltiSnipsJumpBackwardTrigger = '<C-b>'
let g:UltiSnipsSnippetsDir = printf('%s/UltiSnips', $VIMHOME)
let g:snips_author = 'Zandr Martin'

Plug 'airblade/vim-gitgutter'
omap ig <Plug>GitGutterTextObjectInnerPending
omap ag <Plug>GitGutterTextObjectOuterPending
xmap ig <Plug>GitGutterTextObjectInnerVisual
xmap ag <Plug>GitGutterTextObjectOuterVisual

Plug 'mhinz/vim-grepper'
nnoremap g/ :Grepper<CR>
nmap gs <Plug>(GrepperOperator)
xmap gs <Plug>(GrepperOperator)

Plug 'neomake/neomake'
let g:neomake_open_list = 2
let g:neomake_list_height = 10
let g:neomake_error_sign = {'text': '!!', 'texthl': 'NeomakeErrorSign'}
let g:neomake_warning_sign = {'text': '??', 'texthl': 'NeomakeWarningSign'}
let g:neomake_python_python_exe =
  \ substitute(system('which python3'), '\n', '', '')
" }}}

" panels {{{
Plug 'ctrlpvim/ctrlp.vim'
let g:ctrlp_open_multiple_files = '1jr'
if executable('ag')
  let ignores = join(map(copy(g:ignore_patterns),
    \ 'printf("--ignore ''%s''", v:val)'), ' ')
  let g:ctrlp_user_command = printf('ag %s %%s -l --nocolor -g ""', ignores)
  let g:ctrlp_use_caching = 0
  let &grepprg = printf('ag --nogroup --nocolor %s', ignores)
  unlet ignores
endif

Plug 'justinmk/vim-dirvish'
let g:dirvish_mode = ':sort ,^.*[\/],'
nmap - <Plug>(dirvish-toggle)

Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
let g:undotree_WindowLayout = 2
let g:undotree_SetFocusWhenToggle = 1
nnoremap <silent> <C-q> :UndotreeToggle<CR>

Plug 'majutsushi/tagbar', {'on': 'TagbarToggle'}
let g:tagbar_autofocus = 1
let g:tagbar_iconchars = ['+', '-']
nnoremap <silent> <C-t> :TagbarToggle<CR>

Plug 'ap/vim-buftabline'
let g:buftabline_show = 1
let g:buftabline_indicators = 1
let g:buftabline_numbers = 2
let keys = '1234567890qwertyuiop'
let g:buftabline_plug_max = len(keys)
for i in range(g:buftabline_plug_max)
  execute printf('nmap <silent> <M-%s> <Plug>BufTabLine.Go(%d)', keys[i], i+1)
endfor
unlet keys i
" }}}

" text manipulation {{{
Plug 'dhruvasagar/vim-table-mode', {'on': 'TableModeEnable'}
Plug 'henrik/vim-indexed-search'
Plug 'junegunn/vim-peekaboo'
Plug 'nelstrom/vim-visual-star-search'
Plug 'tommcdo/vim-exchange'

let g:mta_filetypes = {
  \ 'html': 1,
  \ 'xhtml': 1,
  \ 'xml': 1,
  \ 'jinja': 1,
  \ 'htmljinja': 1,
  \ 'htmldjango': 1,
  \ }
Plug 'Valloric/MatchTagAlways', {'for': keys(g:mta_filetypes)}

Plug 'tommcdo/vim-lion'
let g:lion_squeeze_spaces = 1

Plug 'zandrmartin/vim-sparkup/'
let g:sparkupExecuteMapping = '<C-^>'
let g:sparkupNextMapping = '<C-f>'
let g:sparkupFiletypes = keys(g:mta_filetypes)
" }}}

" tpope's special section {{{
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
" }}}
call plug#end()
" --- end plugins --- }}}

" --- autocommands --- {{{
augroup rc_commands
  autocmd!

  " there really should be a has('vim_quitting')
  autocmd QuitPre * let w:vim_quitting = 1

  " omni-complete
  autocmd FileType *
    \ if &omnifunc == '' |
    \   set omnifunc=syntaxcomplete#Complete |
    \ endif

  " specify comment types for commentary
  autocmd FileType django,htmldjango,jinja,htmljinja
    \ setlocal commentstring={#%s#}
  autocmd FileType cmake setlocal commentstring=#%s

  " i will never be working with c++
  autocmd BufNewFile,BufReadPost *.c,*.h setlocal filetype=c

  " mutt and mail
  autocmd BufRead /tmp/mutt-*,/private$TMPDIR/mutt-* setlocal filetype=mail
  autocmd BufNewFile,BufReadPost *.muttrc setlocal filetype=muttrc

  " check all the things (except when quitting)
  autocmd BufWritePost *
    \ if !get(w:, 'vim_quitting', 0) |
    \   Neomake |
    \ endif

  " quit even if dirvish or quickfix is open
  autocmd BufEnter *
    \ if winnr('$') == 1 && (&bt ==? 'quickfix' || &bt ==? 'nofile') |
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
  autocmd! BufWinEnter *
    \ if exists('b:winview') |
    \   call winrestview(b:winview) |
    \   unlet b:winview |
    \ endif

  " strip trailing whitespace on most file-types
  autocmd BufWritePre *
    \ if index(['mail', 'snippets', 'conf'], &ft) == -1 |
    \   StripTrailingWhitespace |
    \ endif

  " load fugitive on all buffers
  autocmd BufEnter * call fugitive#detect(expand('%:p'))

  " i edit my vimrc enough i need autocmds dedicated to it #cooldude #sunglasses
  autocmd BufWritePost $MYVIMRC
    \ if !get(w:, 'vim_quitting', 0) |
    \   source $MYVIMRC |
    \ endif

  " close preview window when leaving insert mode
  autocmd InsertLeave * pclose!
augroup END
" --- end autocommands --- }}}

" --- keymaps and commands --- {{{
" typos
command! -bang -nargs=1 -complete=file E e<bang> <args>
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
cnoremap w!! SudoWrite

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
nnoremap <C-Up>    <C-W>+
nnoremap <C-Down>  <C-W>-

" switch windows
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k

" strip trailing whitespace
command! -bar StripTrailingWhitespace %s/\s\+$//e | nohlsearch

" un-dos files with ^M line endings
command! Undos e ++ff=unix | %s///g

" set indentation
command! -bar -nargs=1 SetIndent setlocal softtabstop=<args> shiftwidth=<args>

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
command! -nargs=? CompileSass call utils#compile_sass(<args>)
command! -nargs=1 RFC call utils#rfc(<args>)

" emacs keys in command-line
cnoremap <C-e> <End>
cnoremap <C-a> <Home>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <M-d> <S-Right><Right><C-w>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>
cnoremap <C-d> <Delete>

" hash rocket
imap <expr> <C-l> printf('%s=> ', (completion#check_back_space()) ? '' : ' ')

" function! s:auto_close_block() abort
"   let l:prev = completion#char_before_cursor()
"   return (l:prev == '{') ? : "\<CR>\<C-i>\<CR>}\<Up>\<End>" : "\<CR>"
" endfunction
" inoremap <script> <expr> <CR> <SID>auto_close_block()
" --- end keymaps --- }}}

" --- colors and appearance --- {{{
" colors {{{
set background=dark
if $TERM == 'linux'
  colorscheme default
elseif strftime('%H') > 21 || strftime('%H') < 6
  colorscheme copper
else
  colorscheme mastodon
endif
" }}}

" statusline {{{
function! GitGutterStatus() abort
  let l:fugstat = fugitive#statusline()
  if l:fugstat == ''
    return ''
  endif
  let l:stats = gitgutter#hunk#summary(bufnr('%'))
  let l:line = ''
  let l:line .= (l:stats[0] > 0) ? '+'.l:stats[0] : ''
  let l:line .= (l:stats[1] > 0) ? '~'.l:stats[1] : ''
  let l:line .= (l:stats[2] > 0) ? '-'.l:stats[2] : ''
  return l:fugstat[:-2].l:line.'] '
endfunction

set statusline=%{GitGutterStatus()}
set statusline+=%<%F
set statusline+=%{&ff!='unix'?'\ \ ['.&ff.']':''}
set statusline+=%{strlen(&fenc)&&&fenc!='utf-8'?'\ \ ['.&fenc.']':''}
set statusline+=\ %h%m%r
set statusline+=%{&wrap?'\[wrap]\ ':''}
set statusline+=%=%l,%c%V\ \ \ %P
" }}}
" --- end colors and appearance --- }}}
