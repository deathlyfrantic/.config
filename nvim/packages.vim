Package 'kristijanhusak/vim-packager', {'type': 'opt'}
augroup z-rc-packager
  autocmd!
  autocmd FileType packager nmap <buffer> <M-j> <Plug>(PackagerGotoNextPlugin)
  autocmd FileType packager nmap <buffer> <M-k> <Plug>(PackagerGotoPrevPlugin)
augroup END

" can remove this when nvim 0.5.0 is released (i think?)
Package 'norcalli/nvim.lua'

" filetypes {{{
Package 'rust-lang/rust.vim', {'for': 'rust'}
Package 'cespare/vim-toml', {'for': 'toml'}
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
Package 'racer-rust/vim-racer', {'for': 'rust'}
let g:racer_cmd = trim(system('which racer'))
let g:racer_experimental_completer = 1
augroup z-rc-racer
  autocmd FileType rust nmap <buffer> K <Plug>(rust-doc)
  autocmd FileType rust nmap <buffer> gd <Plug>(rust-def)
augroup END

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

Package 'dense-analysis/ale'
nnoremap <silent> [a <Cmd>ALEPreviousWrap<CR>
nnoremap <silent> ]a <Cmd>ALENextWrap<CR>
nnoremap Q <Cmd>ALEDetail<CR>
augroup z-rc-ale
  autocmd!
  autocmd FileType ale-preview setlocal wrap linebreak
  autocmd FileType typescript setlocal omnifunc=ale#completion#OmniFunc
        \| nmap <buffer> gd <Plug>(ale_go_to_definition)
        \| nmap <buffer> <C-w>i <Plug>(ale_go_to_definition_in_split)
augroup END
let g:ale_fixers = {
      \ '*': ['remove_trailing_lines', 'trim_whitespace'],
      \ 'rust': ['rustfmt'],
      \ 'javascript': ['prettier'],
      \ 'typescript': ['prettier'],
      \ 'json': ['jq'],
      \ 'lua': ['luafmt'],
      \ }
let g:ale_fix_on_save = 1
let g:ale_fix_on_save_ignore = {'mail': ['trim_whitespace']}
let g:ale_rust_cargo_use_clippy = executable('cargo-clippy')
let g:ale_c_clang_options =
      \ '-fsyntax-only -std=c11 -Wall -Wno-unused-parameter -Werror'
" PR to add luafmt to ale here: https://github.com/dense-analysis/ale/pull/3289
" can remove the following when(/if?) it is merged
function! LuaFmtAleFixer(buffer) abort
  return {'command': 'luafmt --stdin --line-width 80 --indent-count 2'}
endfunction
call ale#fix#registry#Add(
      \ 'luafmt', 'LuaFmtAleFixer', ['lua'], 'Fix lua files with luafmt.')
" }}}

" panels {{{
Package 'junegunn/goyo.vim', {'on': 'Goyo'}
let g:goyo_height = '96%'
let g:goyo_width = 82
function! s:goyo_enter() abort
  set noshowmode noshowcmd showtabline=0
  augroup z-rc-goyo-cursorhold
    autocmd CursorHold,CursorHoldI * echo ''
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
  autocmd FileType cmake setlocal commentstring=#%s
  autocmd FileType sql setlocal commentstring=--%s
  autocmd FileType c,typescript setlocal commentstring=//%s
augroup END

Package 'tpope/vim-fugitive'
Package 'tommcdo/vim-fubitive'
Package 'tpope/vim-rhubarb'
nnoremap <silent> <leader>gs :Git<CR>
nnoremap <silent> <leader>gc :Git commit<CR>
nnoremap <silent> <leader>gw :Gwrite<CR>
noremap  <silent> <leader>gb :GBrowse!<CR>

Package 'tpope/vim-dadbod', {'on': 'DB'}
command! DBSqueeze lua require("dbsqueeze").squeeze()
augroup z-rc-dbsqueeze
  autocmd!
  autocmd BufReadPost *.dbout lua require("dbsqueeze").on_load(500)
augroup END
" }}}
