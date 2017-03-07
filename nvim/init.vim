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

    " install vim-plug if it's not already
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

    if !has('nvim')
        let &t_SI = "\<Esc>[6 q"
        let &t_EI = "\<Esc>[2 q"
    endif
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

" sparkup {{{
let g:sparkupExecuteMapping = '<C-^>'
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
    let &grepprg="ag\ --nogroup\ --nocolor ".s:ignore_string
endif
" }}}

" tagbar {{{
let g:tagbar_autofocus = 1
let g:tagbar_iconchars = ['+', '-']
" }}}

" neomake {{{
let g:neomake_open_list = 2
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

" buftabline {{{
let g:buftabline_show = 1
let g:buftabline_indicators = 1
let g:buftabline_numbers = 2
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
    Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python'}
    Plug 'mitsuhiko/vim-jinja',           { 'for': ['htmljinja', 'jinja']}
    Plug 'kchmck/vim-coffee-script',      { 'for': 'coffee'}
    Plug 'rust-lang/rust.vim',            { 'for': 'rust'}
    Plug 'pangloss/vim-javascript',       { 'for': 'javascript'}

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

    " panels
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'justinmk/vim-dirvish'
    Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle'}
    Plug 'sjl/gundo.vim',     { 'on': 'GundoToggle'}
    Plug 'ap/vim-buftabline'

    " text manipulation
    Plug 'henrik/vim-indexed-search'
    Plug 'junegunn/vim-easy-align'
    Plug 'junegunn/vim-peekaboo'
    Plug 'nelstrom/vim-visual-star-search'
    Plug 'rstacruz/sparkup',        {'for': keys(g:mta_filetypes)}
    Plug 'tommcdo/vim-exchange'
    Plug 'Valloric/MatchTagAlways', {'for': keys(g:mta_filetypes)}
    Plug 'dhruvasagar/vim-table-mode'

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

    " my plugins
    for p in ['distill', 'textobj-blanklines']
        if isdirectory(expand('~/src/vim/'.p))
            Plug '~/src/vim/'.p
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
    quit
endif
" --- end plugins --- }}}

" --- general settings --- {{{
set cinoptions+=(0 cinoptions+=:0
set colorcolumn=120
set completeopt-=preview
set cursorline
set expandtab
set fillchars=vert:\│,fold:-
set fileformats=unix,dos,mac
set foldlevel=99
set foldmethod=indent
set formatoptions-=c formatoptions+=jnroql
set gdefault
set hidden
set ignorecase
set inccommand=split
set lazyredraw
set listchars=space:·,eol:¬,tab:▸\ ,trail:·,precedes:↪,extends:↩
set nojoinspaces
set nostartofline
set nowrap
set number
set shiftround
set shiftwidth=4
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

    " omni-complete
    autocmd FileType * if index(['php', 'python'], &ft) == -1 | setlocal omnifunc=syntaxcomplete#Complete | endif

    " specify comment types for commentary
    autocmd FileType c,php setlocal commentstring=//%s
    autocmd FileType django,htmldjango,jinja,htmljinja setlocal commentstring={#%s#}

    " i will never be working with c++
    autocmd BufNewFile,BufReadPost *.c,*.h setlocal filetype=c

    " mutt and mail
    autocmd BufRead /tmp/mutt-* setlocal filetype=mail
    autocmd BufNewFile,BufReadPost *.muttrc setlocal filetype=muttrc

    " check all the things (except when quitting)
    autocmd BufWritePost * call <SID>neomake_check_on_write()
    autocmd QuitPre * let w:neomake_quitting = 1

    " quit even if dirvish or quickfix is open
    autocmd BufEnter *
        \ if winnr('$') == 1 && (&buftype ==? 'quickfix' || &buftype ==? 'nofile') |
        \     if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1 |
        \         quit |
        \     else |
        \         bd! |
        \     endif |
        \ endif

    " see :help last-position-jump
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \     execute "normal! g`\"zvzz" |
        \ endif

    " don't move my position when switching buffers
    autocmd! BufWinLeave * let b:winview = winsaveview()
    autocmd! BufWinEnter * if exists('b:winview') | call winrestview(b:winview) | unlet b:winview

    " strip trailing whitespace on most file-types
    autocmd BufWritePre *
        \ if index(['markdown', 'mail', 'snippets', 'conf'], &ft) == -1 |
        \     %s/\s\+$//e |
        \ endif

    " uglify js files on saving, if they aren't already
    autocmd BufWritePost *.js call <SID>uglify_js(expand('%:p'))

    " 'compile' sass files on saving, if they aren't _something.scss files
    autocmd BufWritePost *.scss
        \ if (executable('sass') || executable('sassc')) && expand('%:t')[0] != '_' |
        \     execute '!sass -t compressed '.expand('%:p').' '.expand('%:p:r').'.css' |
        \ endif

    " 'compile' coffeescript on saving
    autocmd BufWritePost *.coffee
        \ if executable('coffee') |
        \     execute '!coffee -c '.expand('%:p') |
        \ endif |
        \ call <SID>uglify_js(expand('%:p:r').'.js')

    " load fugitive on all buffers
    autocmd BufEnter * call fugitive#detect(getcwd())

    " i edit my vimrc enough i need autocmds dedicated to it #cooldude #sunglasses
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

" hide search highlighting
nnoremap <silent> <Space> :nohlsearch<CR>

" [G]o [B]ack and [G]o [F]orward - why are these C-o and C-i by default that makes no sense
nnoremap gb <C-o>
nnoremap gf <C-i>

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

" prevent dirvish from mapping -
nnoremap - -

" digraphs
digraphs +1 128077
digraphs -1 128078
" --- end keymaps --- }}}

" --- colors and appearance --- {{{
command! Bright set background=light | colorscheme nihil
command! Dark   set background=dark  | colorscheme nihil
Dark
" colorscheme dosedit

" statusline {{{
set statusline=\ %{strlen(fugitive#statusline())?fugitive#statusline().'\ ':''}
set statusline+=%<%F
set statusline+=%{&ff!='unix'?'\ \ ['.&ff.']':''}
set statusline+=%{strlen(&fenc)&&&fenc!='utf-8'?'\ \ ['.&fenc.']':''}
set statusline+=\ %m\ %r%=
set statusline+=%{&wrap?'\[wrap]\ ':''}
set statusline+=%c\ \|\ %l/%L\ \|\ %p%%%(\ %)
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
command! -nargs=? UglifyJS call <SID>uglify_js(<args>)
function! s:uglify_js(...)
    let l:file = a:0 ? a:1 : expand('%:p')
    if executable('uglifyjs') && l:file !~? '.min.js'
        execute '!uglifyjs '.l:file.' -mo '.fnamemodify(l:file, ':r').'.min.'.fnamemodify(l:file, ':e')
    endif
endfunction
" }}}
" --- end miscellaneous --- }}}
