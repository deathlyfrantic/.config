Package 'kristijanhusak/vim-packager', {'type': 'opt'}
augroup z-rc-packager
  autocmd!
  autocmd FileType packager nmap <buffer> <M-j> <Plug>(PackagerGotoNextPlugin)
  autocmd FileType packager nmap <buffer> <M-k> <Plug>(PackagerGotoPrevPlugin)
augroup END

" filetypes {{{
Package 'rust-lang/rust.vim', {'for': 'rust'}
Package 'cespare/vim-toml', {'for': 'toml'}
Package 'Vimjas/vim-python-pep8-indent', {'for': 'python'}
Package 'mitsuhiko/vim-jinja', {'for': ['htmljinja', 'jinja']}
Package 'pangloss/vim-javascript', {'for': 'javascript'}
" }}}

" text objects {{{
Package 'Julian/vim-textobj-variable-segment'
Package 'kana/vim-textobj-user'
Package 'michaeljsmith/vim-indent-object'
Package 'glts/vim-textobj-comment'
Package '~/src/vim/textobj-blanklines'
" }}}

" dev tools {{{
Package 'AndrewRadev/linediff.vim', {'on': 'Linediff'}
Package 'racer-rust/vim-racer', {'for': 'rust'}
let g:racer_cmd = trim(system('which racer'))
let g:racer_experimental_completer = 1

Package 'airblade/vim-gitgutter'
omap ig <Plug>(GitGutterTextObjectInnerPending)
omap ag <Plug>(GitGutterTextObjectOuterPending)
xmap ig <Plug>(GitGutterTextObjectInnerVisual)
xmap ag <Plug>(GitGutterTextObjectOuterVisual)
augroup z-rc-gitgutter
  autocmd!
  autocmd BufEnter,TextChanged,InsertLeave,BufWritePost * GitGutter
  autocmd BufDelete */.git/COMMIT_EDITMSG GitGutterAll
augroup END

Package 'sbdchd/neoformat', {'on': 'Neoformat'}
let g:neoformat_basic_format_trim = 1
augroup z-rc-neoformat
  autocmd!
  autocmd FileType mail let b:neoformat_basic_format_trim = 0
  autocmd FileType yaml let b:neoformat_enabled_yaml = []
  autocmd BufWritePre * if !get(b:, 'no_neoformat') | silent Neoformat | endif
augroup END

Package 'w0rp/ale'
let g:ale_rust_cargo_use_clippy = executable('cargo-clippy')
nnoremap <silent> [a <Cmd>ALEPreviousWrap<CR>
nnoremap <silent> ]a <Cmd>ALENextWrap<CR>
nnoremap Q <Cmd>ALEDetail<CR>
augroup z-rc-ale
  autocmd!
  autocmd FileType ale-preview setlocal wrap linebreak
  autocmd FileType java let b:ale_enabled = 0
augroup END
" }}}

" panels {{{
Package 'junegunn/goyo.vim', {'on': 'Goyo'}
let g:goyo_height = '96%'
let g:goyo_width = 82
function! s:goyo_enter() abort
  set noshowmode noshowcmd showtabline=0
  augroup z-rc-goyo-cursorhold
    autocmd CursorHold * echo ''
  augroup END
endfunction
function! s:goyo_leave() abort
  set showmode showcmd
  call buftabline#update(0)
  autocmd! z-rc-goyo-cursorhold
  augroup! z-rc-goyo-cursorhold
endfunction
augroup z-rc-goyo
  autocmd!
  autocmd User GoyoEnter ++nested call <SID>goyo_enter()
  autocmd User GoyoLeave ++nested call <SID>goyo_leave()
augroup END

Package 'justinmk/vim-dirvish'
let g:dirvish_mode = ':sort ,^.*[\/],'
nmap - <Plug>(dirvish-toggle)

Package 'mbbill/undotree', {'on': 'UndotreeToggle'}
let g:undotree_WindowLayout = 2
let g:undotree_SetFocusWhenToggle = 1
nnoremap <silent> <C-q> :UndotreeToggle<CR>

Package 'majutsushi/tagbar', {'on': 'TagbarToggle'}
let g:tagbar_autofocus = 1
let g:tagbar_iconchars = ['+', '-']
nnoremap <silent> <C-t> <Cmd>TagbarToggle<CR>

Package 'ap/vim-buftabline'
let g:buftabline_show = 1
let g:buftabline_indicators = 1
let g:buftabline_numbers = 2
let keys = '1234567890qwertyuiop'
let g:buftabline_plug_max = len(keys)
for [i, k] in z#enumerate(keys, 1)
  execute printf('nmap <silent> <M-%s> <Plug>BufTabLine.Go(%d)', k, i)
endfor
unlet! keys i k

Package 'wellle/tmux-complete.vim'
let g:tmuxcomplete#trigger = ''
inoremap <C-x><C-t> <Cmd>call completion#wrap('tmuxcomplete#complete')<CR>
" }}}

" text manipulation {{{
Package 'nelstrom/vim-visual-star-search'
Package 'tommcdo/vim-exchange'
Package 'tommcdo/vim-lion'
let g:lion_squeeze_spaces = 1
" }}}

" tpope's special section {{{
Package 'tpope/vim-abolish'
Package 'tpope/vim-apathy'
Package 'tpope/vim-endwise'
Package 'tpope/vim-obsession'
Package 'tpope/vim-repeat'
Package 'tpope/vim-scriptease'
Package 'tpope/vim-sleuth'
Package 'tpope/vim-speeddating'
Package 'tpope/vim-surround'
Package 'tpope/vim-unimpaired'
let g:nremap = {'[a': '', ']a': ''}

Package 'tpope/vim-eunuch'
cnoremap w!! SudoWrite

Package 'tpope/vim-commentary'
augroup z-rc-commentary
  autocmd!
  autocmd FileType django,htmldjango,jinja,htmljinja setlocal cms={#%s#}
  autocmd FileType cmake setlocal commentstring=#%s
  autocmd FileType sql setlocal commentstring=--%s
  autocmd FileType c,typescript setlocal commentstring=//%s
augroup END

Package 'tpope/vim-fugitive'
Package 'tommcdo/vim-fubitive'
Package 'tpope/vim-rhubarb'
nnoremap <silent> <leader>gs :Gstatus<CR>
nnoremap <silent> <leader>gc :Gcommit<CR>
nnoremap <silent> <leader>gw :Gwrite<CR>
noremap  <silent> <leader>gb :Gbrowse!<CR>

Package 'tpope/vim-dadbod', {'on': 'DB'}
function! s:db_command(...) abort
  let cmd = ':DB '
  if exists('b:db_url')
    let cmd .= 'b:db_url '.(a:0 ? a:1.' ' : '')
  endif
  return cmd
endfunction
nnoremap <expr> <leader>db <SID>db_command()
nnoremap <expr> <leader>ds <SID>db_command('SELECT * FROM')
nnoremap <expr> <leader>di <SID>db_command('INSERT INTO')
nnoremap <expr> <leader>du <SID>db_command('UPDATE')
nnoremap <expr> <leader>dd <SID>db_command('DELETE FROM')
" }}}
