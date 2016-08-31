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
        let s:plug_install_command = '!curl -fLo '.$VIMHOME.'/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        silent execute s:plug_install_command
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
let s:ignore_patterns = [
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
nnoremap <silent> <C-x> :GundoToggle<CR>
let g:gundo_preview_bottom = 1
" }}}

" tagbar {{{
nnoremap <silent> <C-t> :TagbarToggle<CR>
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
" let g:deoplete#omni_patterns = {}
" let g:deoplete#omni_patterns.php = '\h\w*\|[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
" }}}

" ctrlp and ag stuff {{{
let g:ctrlp_open_multiple_files = '1jr'
if executable('ag')
    let s:ignore_string = join(map(copy(s:ignore_patterns), '"--ignore ''" . v:val . "''"'), ' ')
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
    \ 'texthl': 'SyntasticError'
    \ }
let g:neomake_warning_sign = {
    \ 'text': '??',
    \ 'texthl': 'SyntasticWarning'
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
    \ 'mako': 1,
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
    Plug 'mitsuhiko/vim-jinja', {'for': ['htmljinja', 'jinja']}
    Plug 'StanAngeloff/php.vim', {'for': 'php'}
    Plug 'hdima/python-syntax', {'for': 'python'}
    Plug 'jeroenbourgois/vim-actionscript', {'for': 'actionscript'}
    Plug 'kchmck/vim-coffee-script', {'for': 'coffee'}
    Plug 'rust-lang/rust.vim', {'for': 'rust'}
    Plug 'othree/yajs.vim', {'for': 'javascript'}
    Plug 'justinmk/vim-syntax-extra', {'for': 'c'}
    Plug 'sophacles/vim-bundle-mako', {'for': 'mako'}

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

    " deoplete
    Plug 'Shougo/deoplete.nvim', {'do': function('VimPlugUpdateRemotePlugins')}
    Plug 'Shougo/neco-vim', {'for': 'vim'}
    Plug 'Shougo/neco-syntax'
    Plug 'davidhalter/jedi', {'for': 'python'}
    Plug 'zchee/deoplete-jedi', {'for': 'python'}
    Plug 'zchee/deoplete-clang', {'for': 'c'}

    " panels
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'justinmk/vim-dirvish'
    Plug 'majutsushi/tagbar', {'on': 'TagbarToggle'}
    Plug 'sjl/gundo.vim', {'on': 'GundoToggle'}

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
    Plug 'tpope/vim-rhubarb'
    Plug 'tpope/vim-scriptease'
    Plug 'tpope/vim-sleuth'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-unimpaired'
    Plug 'tommcdo/vim-fubitive'
    " fubitive ties into fugitive so we'll let it live here

    " colors + vanity
    Plug 'Valloric/MatchTagAlways', {'for': keys(g:mta_filetypes)}
    Plug 'ap/vim-buftabline'
    Plug 'chrisbra/Colorizer', {'on': 'ColorHighlight'}
    Plug 'zandrmartin/vim-distill'
    Plug '~/Code/vim/pistle/'

    " my plugins
    for p in ['pistle', 'distill', 'textobj-blanklines']
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
set formatoptions-=c formatoptions+=n
set hidden
set ignorecase
set lazyredraw
set listchars=space:·,eol:¬,tab:▸\ ,trail:☠,precedes:↪,extends:↩
set nojoinspaces
set nostartofline
set nowrap
set number
set shiftround
set shiftwidth=4
set showcmd
set smartcase
set spellfile=$VIMHOME/custom.utf-8.add,$VIMHOME/local.utf-8.add
set softtabstop=4
set tabstop=4
set title
set ttimeout
set ttimeoutlen=50
set undofile
let &wildignore=join(s:ignore_patterns, ',')
set wildignorecase
set writebackup
" --- end general --- }}}

" --- autocommands --- {{{
augroup rc_commands
    autocmd!

    " make commentary use // for c and php comments
    autocmd FileType c,php setlocal commentstring=//%s

    " i will never be working with c++
    autocmd BufNewFile,BufReadPost *.c,*.h setlocal filetype=c

    " mutt and mail
    autocmd BufRead /tmp/mutt-* setlocal spell textwidth=72 | Wrap
    autocmd BufNewFile,BufReadPost *.muttrc setlocal filetype=muttrc

    " check all the things (except when quitting)
    autocmd BufWritePost * call <SID>neomake_check_on_write()
    autocmd QuitPre * let w:neomake_quitting = 1

    " quit even if dirvish or quickfix is open
    autocmd BufEnter *
        \ if winnr('$') == 1 && (&buftype ==? 'quickfix' || &buftype ==? 'nofile') |
        \   quit |
        \ endif

    " see :help last-position-jump
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   execute "normal! g`\"zvzz" |
        \ endif

    " there is zero chance i want python 2 syntax, also highlight `self`s
    autocmd BufNewFile,BufReadPost *.py execute 'Python3Syntax' | syntax match pythonSelf /self/

    " markdown options. why does .md default to modula2 what even is that
    autocmd BufNewFile,BufReadPost *.md setlocal spell filetype=markdown textwidth=120 wrapmargin=0 | Wrap

    " strip trailing whitespace on most file-types
    autocmd BufWritePre *
        \ if index(['markdown', 'mail', 'snippets'], &ft) == -1 |
        \   %s/\s\+$//e |
        \ endif

    " set .mako files to highlight as mako
    autocmd BufNewFile,BufReadPost *.mako setlocal filetype=mako

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

" zip to end
inoremap <C-l> <Esc>l"zd<Space>$"zpa
nnoremap <M-l> "zd<Space>m`$"zp``

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
map <F1> <Del>
map! <F1> <Del>
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
nnoremap <C-Left> <C-W><
nnoremap <C-Right> <C-W>>
nnoremap <C-Up> <C-W>+
nnoremap <C-Down> <C-W>-

" switch windows
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k

" popup menu completion selection
inoremap <silent> <Tab> <C-R>=pumvisible() ? "\<lt>C-N>" : "\<lt>Tab>"<CR>
inoremap <silent> <S-Tab> <C-R>=pumvisible() ? "\<lt>C-P>" : "\<lt>Tab>"<CR>

" strip trailing whitespace
command! StripTrailingWhitespace %s/\s\+$//e

" maintain visual mode for indenting
vnoremap < <gv
vnoremap > >gv
" --- end keymaps --- }}}

" --- colors and appearance --- {{{
" colorscheme distill
colorscheme pistle

highlight User1 ctermbg=16 ctermfg=254 guibg=#000000 guifg=#e4e4e4 cterm=bold gui=bold

" statusline {{{
set statusline=%<
set statusline+=\ %{fnamemodify(expand('%'),':~')}
set statusline+=%{strlen(&filetype)?'\ \ ·\ '.&filetype:''}
set statusline+=%{strlen(&fileformat)?'\ \ ·\ '.&fileformat:''}
set statusline+=%{strlen(&fileencoding)?'\ \ ·\ '.&fileencoding.'\ \ \ ':'\ \ \ '}
set statusline+=%#SyntasticError#%{&readonly?'\ \ read-only\ ':''}%*
set statusline+=%1*%{&modified?'\ \ modified\ ':''}%*
set statusline+=%=
set statusline+=\ \ \ cwd:\ %{fnamemodify(getcwd(),':~')}
set statusline+=\ ·\ %{&wrap?'wrap\ ·\ ':''}%c\ ·\ %l/%L\ ·\ %p%%%{'\ '}
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

" dirvish {{{
nmap <C-o> <Plug>DirvishToggle
nnoremap <silent> <Plug>DirvishToggle :<C-u>call <SID>dirvish_toggle()<CR>

function! s:dirvish_toggle() abort
    let l:last_buffer = bufnr('$')
    let l:i = 1
    let l:dirvish_already_open = 0

    while l:i <= l:last_buffer
        if bufexists(l:i) && bufloaded(l:i) && getbufvar(l:i, '&filetype') ==? 'dirvish'
            let l:dirvish_already_open = 1
            execute ':'.l:i.'bd!'
        endif
        let l:i += 1
    endwhile

    if !l:dirvish_already_open
        35vsp +Dirvish
    endif
endfunction

function! s:dirvish_open() abort
    let l:line = getline('.')
    if l:line =~? '/$'
        call dirvish#open('edit', 0)
    else
        call <SID>dirvish_toggle()
        execute 'e '.l:line
    endif
endfunction

augroup dirvish_commands
    autocmd!

    autocmd FileType dirvish call fugitive#detect(@%)
    autocmd FileType dirvish nnoremap <silent> <buffer> <C-r> :<C-u>Dirvish %<CR>
    autocmd FileType dirvish unmap <silent> <buffer> <CR>
    autocmd FileType dirvish nnoremap <silent> <buffer> <CR> :<C-u> call <SID>dirvish_open()<CR>
    autocmd FileType dirvish setlocal nonumber norelativenumber statusline=%F
    autocmd FileType dirvish silent! keeppatterns g@\v/\.[^\/]+/?$@d
    autocmd FileType dirvish execute ':sort r /[^\/]$/'

    for pat in s:ignore_patterns
        execute 'autocmd FileType dirvish silent! keeppatterns g@\v/'.pat.'/?$@d'
    endfor
augroup END
" }}}

" information superhighway {{{
nmap gw <Plug>Websearch
xmap gw <Plug>Websearch
nnoremap <silent> <Plug>Websearch :set opfunc=<SID>google_operator<CR>g@
xnoremap <silent> <Plug>Websearch :<C-u>call <SID>google_operator(visualmode())<CR>

command! -nargs=1 Web call <SID>browser(<f-args>)
command! -nargs=1 Google call <SID>google(<f-args>)

function! s:google_operator(type) abort
    let l:regsave = @@
    let l:selsave = &selection
    let &selection = 'inclusive'

    if a:type =~? 'v'
        silent execute "normal! gvy"
    elseif a:type == 'line'
        silent execute "normal! '[V']y"
    else
        silent execute "normal! `[v`]y"
    endif

    let l:url = @@
    let &selection = selsave
    let @@ = regsave

    call <SID>google(l:url)
endfunction

function! s:google(url)
    if a:url =~? 'http'
        let l:url = a:url
    else
        let l:url = 'http://google.com/search?q='.a:url
    endif
    call <SID>browser(l:url)
endfunction

function! s:browser(url)
    let l:command = '!xdg-open "'.a:url.'"'
    silent execute l:command
endfunction
" }}}

" handy wrap/unwrap mappings {{{
command! -nargs=? Wrap call <SID>wrap(<f-args>)
command! Unwrap call <SID>unwrap()

function! s:wrap(...)
    let s:orig_colcol = &colorcolumn
    let s:orig_tw = &textwidth

    if a:0
        exec 'setlocal textwidth='.a:1.' colorcolumn='.a:1
    endif

    setlocal wrap linebreak
    inoremap <Up> <C-o>gk
    inoremap <Down> <C-o>gj
    nnoremap k gk
    nnoremap gk k
    nnoremap j gj
    nnoremap gj j
endfunction

function! s:unwrap()
    setlocal nowrap nolinebreak
    exec 'setlocal textwidth='.s:orig_tw.' colorcolumn='.s:orig_colcol
    iunmap <Up>
    iunmap <Down>
    unmap k
    unmap gk
    unmap j
    unmap gj
endfunction
" }}}

" set indent spacing based on filetype
command! -nargs=? SetIndent call <SID>set_indent_level(<f-args>)

function! s:set_indent_level(...)
    let l:levels = {
        \ 'xml': 2,
        \ 'html': 2,
        \ 'htmldjango': 2,
        \ 'htmljinja': 2,
        \ 'django': 2,
        \ 'mako': 2,
        \ }

    if a:0
        let l:level = a:1
    else
        let l:level = get(l:levels, &filetype, 4)
    endif

    for l:cmd in ['softtabstop', 'shiftwidth']
        execute 'setlocal '.l:cmd.'='.l:level
    endfor
endfunction
" --- end miscellaneous functions --- }}}
