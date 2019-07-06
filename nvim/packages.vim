Package 'kristijanhusak/vim-packager', {'type': 'opt'}

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
let g:racer_cmd = z#rtrim(system('which racer'))
let g:racer_experimental_completer = 1

Package 'airblade/vim-gitgutter'
omap ig <Plug>GitGutterTextObjectInnerPending
omap ag <Plug>GitGutterTextObjectOuterPending
xmap ig <Plug>GitGutterTextObjectInnerVisual
xmap ag <Plug>GitGutterTextObjectOuterVisual
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
  autocmd FileType ale-preview Wrap
  autocmd FileType java let b:ale_enabled = 0
augroup END
" }}}

" panels {{{
Package 'ctrlpvim/ctrlp.vim', {'on': '<Plug>(ctrlp)'}
nmap <C-p> <Plug>(ctrlp)
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
  unlet! igs
endif

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
Package 'junegunn/vim-peekaboo'
Package 'nelstrom/vim-visual-star-search'
Package 'tommcdo/vim-exchange'
Package 'tommcdo/vim-lion'
let g:lion_squeeze_spaces = 1

Package 'google/vim-searchindex'
nmap * *N
nmap # #N
" }}}

" tpope's special section {{{
Package 'tpope/vim-abolish'
Package 'tpope/vim-apathy'
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
  autocmd FileType c,php setlocal commentstring=//%s
augroup END

Package 'tpope/vim-fugitive'
Package 'tommcdo/vim-fubitive'
Package 'tpope/vim-rhubarb'
nnoremap <silent> <leader>gs :Gstatus<CR>
nnoremap <silent> <leader>gc :Gcommit<CR>
nnoremap <silent> <leader>gw :Gwrite<CR>
noremap <silent> <leader>gb :Gbrowse!<CR>

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
