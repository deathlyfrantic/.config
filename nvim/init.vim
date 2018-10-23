" --- startup processes --- {{{
if has('vim_starting')
  " stuff that should only have to happen once
  let $VIMHOME = split(&runtimepath, ',')[0]
  set termguicolors

  " kill default vim plugins i don't want
  let g:loaded_vimballPlugin = 'v35'
  let g:loaded_netrwPlugin = 'v153'
  let g:loaded_netrw = 'v153'
  let g:loaded_tutor_mode_plugin = 1
  let g:loaded_2html_plugin = 'vim7.4_v1'

  " install vim-plug if it's not already
  let plug_path = expand('$VIMHOME/autoload/plug.vim')
  if !filereadable(plug_path)
    execute '!curl -fLo' plug_path '--create-dirs'
      \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall | UpdateRemotePlugins
    autocmd VimEnter * nested source $MYVIMRC
  endif
  unlet! plug_path
endif
" --- end startup --- }}}

" --- general settings --- {{{
set cinoptions+=:0,(0
set colorcolumn=+1
set completeopt-=preview
set completefunc=completion#snippet
set cursorline
set expandtab
set fillchars=fold:-
set fileformats=unix,dos,mac
set foldlevel=99
set foldmethod=indent
set formatoptions+=nrol
set gdefault
set hidden
set ignorecase
set inccommand=split
set lazyredraw
set listchars=space:␣,eol:¬,tab:▸⁃,trail:␣,precedes:⤷,extends:⤶
set matchpairs+=<:>
set nojoinspaces
set nostartofline
set nowrap
set number
set shiftround
set shiftwidth=4
set shortmess-=F
set smartcase
set spellfile=$VIMHOME/spell/custom.utf-8.add,$VIMHOME/spell/local.utf-8.add
set softtabstop=4
set textwidth=80
set title
set undofile
set wildignore+=node_modules/,package-lock.json,*.min.js
set wildignore+=__pycache__/,*.pyc,Pipfile.lock,*.egg-info/
set wildignore+=Cargo.lock
set wildignore+=.git,.gitmodules
set wildignore+=*.swp
set wildignore+=*.sqlite3
set wildignore+=.sass-cache
set wildignore+=.DS_Store
set wildignorecase
" --- end general settings --- }}}

" --- plugins --- {{{
call plug#begin(expand('$VIMHOME/plugged'))
" filetypes {{{
Plug 'rust-lang/rust.vim', {'for': 'rust'}
Plug 'cespare/vim-toml', {'for': 'toml'}
Plug 'Vimjas/vim-python-pep8-indent', {'for': 'python'}
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
Plug 'deathlyfrantic/vim-textobj-blanklines'
" }}}

" dev tools {{{
Plug 'racer-rust/vim-racer', {'for': 'rust'}
let g:racer_cmd = z#sys_chomp('which racer')
let g:racer_experimental_completer = 1

Plug 'ludovicchabant/vim-gutentags'
let g:gutentags_ctags_tagfile = '.ctags'

Plug 'airblade/vim-gitgutter'
omap ig <Plug>GitGutterTextObjectInnerPending
omap ag <Plug>GitGutterTextObjectOuterPending
xmap ig <Plug>GitGutterTextObjectInnerVisual
xmap ag <Plug>GitGutterTextObjectOuterVisual
augroup z-rc-gitgutter
  autocmd!
  autocmd BufEnter,TextChanged,InsertLeave,BufWritePost * GitGutter
  autocmd BufDelete */.git/COMMIT_EDITMSG GitGutterAll
augroup END

Plug 'mhinz/vim-grepper'
nnoremap g/ :Grepper<CR>
nmap gs <Plug>(GrepperOperator)
xmap gs <Plug>(GrepperOperator)
let g:grepper = {
  \ 'tools': ['rg', 'git', 'grep'],
  \ 'rg': {'grepprg': 'rg -H --no-heading -S --vimgrep'}
  \ }

Plug 'sbdchd/neoformat'
augroup z-rc-neoformat
  autocmd!
  autocmd BufWritePre *
    \ if !get(b:, 'no_neoformat', 0) |
    \   silent Neoformat |
    \ endif
augroup END

Plug 'w0rp/ale'
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
nnoremap <silent> [a :ALEPreviousWrap<Enter>
nnoremap <silent> ]a :ALENextWrap<Enter>
augroup z-rc-ale
  autocmd!
  autocmd FileType ale-preview Wrap
augroup END
" }}}

" panels {{{
Plug 'ctrlpvim/ctrlp.vim'
let g:ctrlp_open_multiple_files = '1jr'
let g:ctrlp_prompt_mappings = {
  \ 'PrtSelectMove("j")': ['<C-n>', '<C-j>'],
  \ 'PrtSelectMove("k")': ['<C-p>', '<C-k>'],
  \ 'PrtHistory(-1)': ['<Down>'],
  \ 'PrtHistory(1)':  ['<Up>'],
  \ }
if executable('rg')
  let igs = join(map(split(&wildignore, ','), {i, v -> printf("-g '!%s'", v)}))
  let g:ctrlp_user_command = printf('rg %s %%s --files -g ""', igs)
  let g:ctrlp_use_caching = 0
  let &grepprg = printf('rg --vimgrep %s $*', igs)
  set grepformat=%f:%l:%c:%m
  unlet! igs
endif

Plug 'justinmk/vim-dirvish'
let g:dirvish_mode = ':sort ,^.*[\/],'
nmap - <Plug>(dirvish-toggle)

Plug 'sjl/gundo.vim', {'on': 'GundoToggle'}
let g:gundo_prefer_python3 = 1
let g:gundo_preview_bottom = 1
nnoremap <silent> <C-q> :GundoToggle<CR>

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
for [i, k] in z#enumerate(keys, 1)
  execute printf('nmap <silent> <M-%s> <Plug>BufTabLine.Go(%d)', k, i)
endfor
unlet! keys i k
" }}}

" text manipulation {{{
Plug 'junegunn/vim-peekaboo'
Plug 'nelstrom/vim-visual-star-search'
Plug 'tommcdo/vim-exchange'
Plug 'tommcdo/vim-lion'
let g:lion_squeeze_spaces = 1

Plug 'google/vim-searchindex'
nmap * *N
nmap # #N

Plug 'AndrewRadev/switch.vim'
let g:switch_mapping = 'Q'
let g:switch_custom_definitions = [['on', 'off'], ['yes', 'no']]
" }}}

" tpope's special section {{{
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-apathy'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-scriptease'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
let g:nremap = {'[a': '', ']a': ''}

Plug 'tpope/vim-eunuch'
cnoremap w!! SudoWrite

Plug 'tpope/vim-commentary'
augroup z-rc-commentary
  autocmd!
  autocmd FileType django,htmldjango,jinja,htmljinja setlocal cms={#%s#}
  autocmd FileType cmake setlocal commentstring=#%s
  autocmd FileType sql setlocal commentstring=--%s
  autocmd FileType c,php setlocal commentstring=//%s
augroup END

Plug 'tpope/vim-fugitive'
Plug 'tommcdo/vim-fubitive'
Plug 'tpope/vim-rhubarb'
nnoremap <silent> <leader>gs :Gstatus<CR>
nnoremap <silent> <leader>gc :Gcommit<CR>
nnoremap <silent> <leader>gw :Gwrite<CR>
noremap <silent> <leader>gb :Gbrowse!<CR>
augroup z-rc-fugitive
  autocmd!
  autocmd BufEnter * call FugitiveDetect(@%)
augroup END

Plug 'tpope/vim-dadbod', {'on': 'DB'}
function! s:db_command(...) abort
  let cmd = ':DB '
  if exists('b:db_url')
    let cmd .= 'b:db_url '
    let cmd .= a:0 ? a:1.' ' : ''
  endif
  return cmd
endfunction
nnoremap <expr> <leader>db <SID>db_command()
nnoremap <expr> <leader>ds <SID>db_command('SELECT * FROM')
nnoremap <expr> <leader>di <SID>db_command('INSERT INTO')
nnoremap <expr> <leader>du <SID>db_command('UPDATE')
nnoremap <expr> <leader>dd <SID>db_command('DELETE FROM')
" }}}
call plug#end()
" --- end plugins --- }}}

" --- autocommands --- {{{
augroup z-rc-commands
  autocmd!

  " omni-complete
  autocmd FileType *
    \ if &omnifunc == '' |
    \   set omnifunc=syntaxcomplete#Complete |
    \ endif

  " custom filetype overrides
  autocmd BufNewFile,BufReadPost *.c,*.h setlocal filetype=c
  autocmd BufRead /tmp/mutt-*,/private$TMPDIR/mutt-* setlocal filetype=mail
  autocmd BufNewFile,BufReadPost *.muttrc setlocal filetype=muttrc
  autocmd BufNewFile,BufReadPost .clang-format setlocal filetype=yaml
  autocmd BufNewFile,BufReadPost *.snippets setlocal filetype=snippets

  " quit even if dirvish or quickfix is open
  autocmd BufEnter *
    \ if winnr('$') == 1 && (&bt == 'quickfix' || &ft == 'dirvish') |
    \   if len(filter(getbufinfo(), {_, b -> b.listed})) == 1 |
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
    \   unlet! b:winview |
    \ endif

  " no line numbers in term
  autocmd! TermOpen * setlocal nonumber

  " i edit my vimrc enough i need autocmds dedicated to it #cooldude #sunglasses
  autocmd BufWritePost $MYVIMRC nested source $MYVIMRC | SetIndent 2
  autocmd BufWritePost $VIMHOME/plugin/*.vim exec 'source' expand('<afile>')
  autocmd BufWritePost $VIMHOME/colors/*.vim exec 'color' expand('<afile>:t:r')
augroup END
" --- end autocommands --- }}}

" --- keymaps and commands --- {{{
" typos
command! -bang -nargs=1 -complete=file E e<bang> <args>
command! -bang -nargs=1 -complete=help H h<bang> <args>
command! -bang Q q<bang>
command! -bang Qa qa<bang>
command! -bang QA qa<bang>
command! -bang Wq wq<bang>
command! -bang WQ wq<bang>
command! -bang BD Bd<bang>

" don't change window layout when deleting buffer
function! s:buf_delete(bufnum, bang) abort
  if getbufvar(a:bufnum, '&modified') && a:bang == ''
    let m = 'E89: No write since last change for buffer %d (add ! to override)'
    call z#echoerr(printf(m, a:bufnum))
    return
  endif
  if bufexists(0) && buflisted(0)
    buffer #
  else
    for buf in reverse(getbufinfo())
      if buf.listed && buf.bufnr != a:bufnum
        execute 'buffer' buf.bufnr
        break
      endif
    endfor
  endif
  execute 'bd'.a:bang a:bufnum
endfunction
command! -bang -bar Bdelete call s:buf_delete(winbufnr(0), <q-bang>)

" auto linenumbers
function! s:auto_hide_gutters() abort
  for w in getwininfo()
    let bufnum = winbufnr(w.winid)
    if getbufvar(bufnum, '&buftype') =~ 'terminal\|help\|nofile'
      continue
    endif
    let tw = getbufvar(bufnum, '&textwidth')
    if tw == 0
      continue
    endif
    call setwinvar(w.winid, '&signcolumn', w.width <= tw + 2 ? 'no' : 'auto')
    call setwinvar(w.winid, '&number', w.width <= tw + 6 ? 0 : 1)
  endfor
endfunction
augroup z-rc-auto-hide-gutters
  autocmd!
  autocmd VimEnter,VimResized,WinEnter,BufWinEnter * call s:auto_hide_gutters()
augroup END

" select last-pasted text
nnoremap gV `[v`]

" turns out i do not need an escape key
inoremap jk <Esc>
tnoremap jk <C-\><C-n>

" why isn't this default, idgaf about vi-compatibility
nmap Y y$

" current directory in command-line
cnoremap <expr> %% fnameescape(expand('%:p:h')).'/'

" write then delete buffer; akin to wq
cnoremap wbd Wbd
command! -bang Wbd w<bang> | Bd<bang>

" hide search highlighting
nnoremap <silent> <Space> :nohlsearch<CR>

" resize windows
nnoremap <silent> <C-Left>  <C-W><:<C-U>call <SID>auto_hide_gutters()<CR>
nnoremap <silent> <C-Right> <C-W>>:<C-U>call <SID>auto_hide_gutters()<CR>
nnoremap <silent> <C-Up>    <C-W>+
nnoremap <silent> <C-Down>  <C-W>-

" switch windows
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k

" strip trailing whitespace
command! -bar StripTrailingWhitespace %s/\s\+$//e | nohlsearch
augroup z-rc-trailing-whitespace
  autocmd!
  autocmd BufWritePre *
    \ if &ft !~? 'mail\|snippets\|conf' |
    \   StripTrailingWhitespace |
    \ endif
augroup END

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
command! -nargs=1 RFC call z#preview(system('rfc '.<args>))

" run tests (see plugin/run-tests.vim)
nmap <silent> <leader>t <Plug>(run-test-nearest)
nmap <silent> <leader>T <Plug>(run-test-file)
nmap <silent> <leader><C-t> <Plug>(run-test-suite)

" copy entire buffer to system clipboard
nnoremap <leader>a m`gg"+yG``

" insert a single space
nnoremap <leader><Space> i<Space><Esc>

" arrows
function! s:arrow(fat) abort
  let before = completion#check_back_space() ? '' : ' '
  let arrow = a:fat ? '=>' : '->'
  let [line, col] = [getline('.'), col('.') - 1]
  let after = (len(line) <= col || line[col] !~ '^\s*$') ? ' ' : "\<Right>"
  return before.arrow.after
endfunction
imap <expr> <C-j> <SID>arrow(0)
imap <expr> <C-l> <SID>arrow(1)
augroup z-rc-arrows
  autocmd!
  autocmd FileType c,php imap <buffer> <C-j> ->
augroup END

" quickfix
function! s:quickfix_toggle() abort
  let qf = filter(getbufinfo(), {_, b -> getbufvar(b.bufnr, '&ft') == 'qf'})
  return len(qf) ? ":cclose\<CR>" : ":copen\<CR>"
endfunction
nnoremap <silent> <expr> <leader>q <SID>quickfix_toggle()
augroup z-rc-quickfix
  autocmd!
  autocmd FileType qf nnoremap <silent> <buffer> <C-c> :cclose<CR> |
    \ nnoremap <silent> <buffer> q :cclose<CR>
augroup END

" close all open man pages
function! s:close_man_pages() abort
  let bufs = filter(getbufinfo(), {_, b -> b.listed && b.name =~? '^man://'})
  execute 'bd!' join(map(bufs, {_, b -> b.bufnr}), ' ')
endfunction
command! ManClose call <SID>close_man_pages()
" --- end keymaps --- }}}

" --- colors and appearance --- {{{
" colors {{{
set background=dark
if strftime('%H') > 19 || strftime('%H') < 9
  colorscheme copper
else
  colorscheme mastodon
endif
let g:terminal_color_0  = '#2e3436'
let g:terminal_color_1  = '#cc0000'
let g:terminal_color_2  = '#4e9a06'
let g:terminal_color_3  = '#c4a000'
let g:terminal_color_4  = '#3465a4'
let g:terminal_color_5  = '#75507b'
let g:terminal_color_6  = '#0b939b'
let g:terminal_color_7  = '#d3d7cf'
let g:terminal_color_8  = '#555753'
let g:terminal_color_9  = '#ef2929'
let g:terminal_color_10 = '#8ae234'
let g:terminal_color_11 = '#fce94f'
let g:terminal_color_12 = '#729fcf'
let g:terminal_color_13 = '#ad7fa8'
let g:terminal_color_14 = '#00f5e9'
let g:terminal_color_15 = '#eeeeec'
" }}}

" statusline {{{
function! GitStatus() abort
  let status = FugitiveStatusline()[:-2]
  if status == ''
    return ''
  endif
  for [sym, num] in z#zip(['+', '~', '-'], gitgutter#hunk#summary(bufnr('%')))
    let status .= num ? sym.num : ''
  endfor
  return status.'] '
endfunction

set statusline=%{GitStatus()}
set statusline+=%<%F
set statusline+=%{&ff!='unix'?'\ ['.&ff.']':''}
set statusline+=%{strlen(&fenc)&&&fenc!='utf-8'?'\ \ ['.&fenc.']':''}
set statusline+=\ %h%m%r%=
set statusline+=%{&wrap?'\[wrap]\ ':''}
set statusline+=%{&paste?'\[paste]\ ':''}
set statusline+=%{gutentags#statusline('[Gutentags:\ ',']')}
set statusline+=%{ObsessionStatus()}
set statusline+=\ \ \ %l,%c%V\ \ \ %P
" }}}
" --- end colors and appearance --- }}}
