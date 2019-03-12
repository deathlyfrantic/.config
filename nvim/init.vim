" --- startup processes --- {{{
if has('vim_starting')
  " stuff that should only have to happen once
  let $VIMHOME = split(&runtimepath, ',')[0]

  " kill default vim plugins i don't want
  let g:loaded_vimballPlugin = 'v35'
  let g:loaded_netrwPlugin = 'v153'
  let g:loaded_netrw = 'v153'
  let g:loaded_tutor_mode_plugin = 1
  let g:loaded_2html_plugin = 'vim7.4_v1'
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
set omnifunc=syntaxcomplete#Complete
set shiftround
set shiftwidth=4
set shortmess-=F
set smartcase
set spellfile=$VIMHOME/spell/custom.utf-8.add,$VIMHOME/spell/local.utf-8.add
set softtabstop=4
set textwidth=80
set title
set undofile
set wildignore+=node_modules/,package-lock.json,*.min.js    " javascript
set wildignore+=__pycache__/,*.pyc,Pipfile.lock,*.egg-info/ " python
set wildignore+=Cargo.lock,*/target/*                       " rust
set wildignore+=.git,.gitmodules                            " git
set wildignore+=*.swp                                       " vim
set wildignore+=.DS_Store                                   " macos
set wildignorecase
" --- end general settings --- }}}

" --- autocommands --- {{{
augroup filetypedetect
  autocmd BufNewFile,BufReadPost *.c,*.h setlocal filetype=c
  autocmd BufRead /tmp/mutt-*,/private$TMPDIR/mutt-* setlocal filetype=mail
  autocmd BufNewFile,BufReadPost *.muttrc setlocal filetype=muttrc
  autocmd BufNewFile,BufReadPost .clang-format setlocal filetype=yaml
  autocmd BufNewFile,BufReadPost *.snippets setlocal filetype=snippets
augroup END

augroup z-rc-commands
  autocmd!

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
  autocmd BufWritePost $VIMHOME/{plugin,autoload}/*.vim
        \ execute 'source' expand('<afile>')
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
    call z#echoerr(m, a:bufnum)
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

" fit current window to contents
command! Fit silent! execute 'resize' line('$')

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
nnoremap <silent> <C-Left>  <C-W><
nnoremap <silent> <C-Right> <C-W>>
nnoremap <silent> <C-Up>    <C-W>+
nnoremap <silent> <C-Down>  <C-W>-

" switch windows
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k

" open terminal split
nnoremap <C-W><C-t> :botright vsp +term<CR>:startinsert<CR>

" un-dos files with ^M line endings
command! Undos e ++ff=unix | %s/\r//g

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
  autocmd FileType vim imap <buffer> <expr> <C-j>
        \ completion#char_before_cursor() == "{" ? "-> " : <SID>arrow(0)
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
if len($COLORTERM) " heuristic to determine whether we're using terminal.app
  set termguicolors
  if strftime('%H') > 19 || strftime('%H') < 9
    colorscheme copper
  else
    colorscheme gaia
  endif
else
  colorscheme album-256
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
set statusline+=%{ObsessionStatus()}
set statusline+=\ \ \ %l,%c%V\ \ \ %P
" }}}
" --- end colors and appearance --- }}}
