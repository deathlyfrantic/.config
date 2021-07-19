local packer_path = vim.fn.stdpath("config")
  .. "/pack/packer/start/packer.nvim"

local need_to_compile = false

if vim.fn.isdirectory(packer_path) ~= 1 then
  os.execute("git clone github:wbthomason/packer.nvim " .. packer_path)
  vim.api.nvim_echo({ { "Installed packer.nvim", "WarningMsg" } }, false, {})
  need_to_compile = true
end

local packer = require("packer")
local use = packer.use

packer.init({ package_root = vim.fn.stdpath("config") .. "/pack" })

use("wbthomason/packer.nvim")

use({ "rust-lang/rust.vim", ft = "rust" })
use({ "cespare/vim-toml", ft = "toml" })
use({ "pangloss/vim-javascript", ft = "javascript" })

use("Julian/vim-textobj-variable-segment")
use("kana/vim-textobj-user")
use("michaeljsmith/vim-indent-object")
use("glts/vim-textobj-comment")
use("~/src/vim/textobj-blanklines")

use({
  "airblade/vim-gitgutter",
  config = [=[vim.cmd([[
    omap ig <Plug>(GitGutterTextObjectInnerPending)
    omap ag <Plug>(GitGutterTextObjectOuterPending)
    xmap ig <Plug>(GitGutterTextObjectInnerVisual)
    xmap ag <Plug>(GitGutterTextObjectOuterVisual)
    augroup z-rc-gitgutter
      autocmd!
      autocmd BufEnter,TextChanged,InsertLeave,BufWritePost * GitGutter
      autocmd BufDelete */.git/COMMIT_EDITMSG GitGutterAll
    augroup END
    ]])
  ]=],
})

use({
  "dense-analysis/ale",
  config = [=[vim.cmd([[
    nnoremap <silent> [a <Cmd>ALEPreviousWrap<CR>
    nnoremap <silent> ]a <Cmd>ALENextWrap<CR>
    nnoremap Q <Cmd>ALEDetail<CR>
    augroup z-rc-ale
      autocmd!
      autocmd FileType ale-preview setlocal wrap linebreak
      autocmd FileType ale-preview.message setlocal colorcolumn=0
      autocmd FileType rust,typescript setlocal omnifunc=ale#completion#OmniFunc | nmap <buffer> gd <Plug>(ale_go_to_definition) | nmap <buffer> K <Plug>(ale_hover) | nmap <buffer> <C-w>i <Plug>(ale_go_to_definition_in_split)
    augroup END
    let g:ale_hover_to_floating_preview = 1
    let g:ale_floating_window_border = repeat([' '], 6)
    let g:ale_fixers = { '*': ['remove_trailing_lines', 'trim_whitespace'], 'rust': ['rustfmt'], 'javascript': ['prettier'], 'javascriptreact': ['prettier'], 'typescript': ['prettier'], 'typescriptreact': ['prettier'], 'json': ['jq'], 'lua': ['stylua'], }
    let g:ale_fix_on_save = 1
    let g:ale_fix_on_save_ignore = {'mail': ['trim_whitespace']}
    let g:ale_rust_cargo_use_clippy = executable('cargo-clippy')
    if executable('rust-analyzer')
      let g:ale_linters = {'rust': ['analyzer', 'cargo']}
    endif
    let g:ale_c_clang_options = '-fsyntax-only -std=c11 -Wall -Wno-unused-parameter -Werror'
    let g:ale_lua_stylua_options = '--config-path ' .. join([stdpath('config'), 'lua', 'stylua.toml'], '/')
    ]])
  ]=],
})

use({
  "junegunn/goyo.vim",
  cmd = "Goyo",
  config = [=[vim.cmd([[
    let g:goyo_height = '96%'
    let g:goyo_width = 82
    function! Goyo_enter() abort
      set noshowmode noshowcmd showtabline=0
      augroup z-rc-goyo-cursorhold
        autocmd CursorHold,CursorHoldI * echo ''
      augroup END
    endfunction
    function! Goyo_leave() abort
      set showmode showcmd
      call buftabline#update(0)
      autocmd! z-rc-goyo-cursorhold
      augroup! z-rc-goyo-cursorhold
    endfunction
    augroup z-rc-goyo
      autocmd!
      autocmd User GoyoEnter ++nested call Goyo_enter()
      autocmd User GoyoLeave ++nested call Goyo_leave()
    augroup END
    ]])
  ]=],
})

use({
  "justinmk/vim-dirvish",
  config = [=[vim.cmd([[
    let g:dirvish_mode = ':sort ,^.*[\/],'
    nmap - <Plug>(dirvish-toggle)
    ]])
  ]=],
})

use({
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  config = [=[vim.cmd([[
    let g:undotree_WindowLayout = 2
    let g:undotree_SetFocusWhenToggle = 1
    nnoremap <silent> <C-q> :UndotreeToggle<CR>
    ]])
  ]=],
})

use({
  "preservim/tagbar",
  cmd = "TagbarToggle",
  config = [=[vim.cmd([[
    let g:tagbar_autofocus = 1
    let g:tagbar_iconchars = ['+', '-']
    nnoremap <silent> <C-t> <Cmd>TagbarToggle<CR>
    ]])
  ]=],
})

use({
  "ap/vim-buftabline",
  config = [=[vim.cmd([[
    let g:buftabline_show = 1
    let g:buftabline_indicators = 1
    let g:buftabline_numbers = 2
    let keys = '1234567890qwertyuiop'
    let g:buftabline_plug_max = len(keys)
    for [i, k] in z#enumerate(keys, 1)
      execute printf('nmap <silent> <M-%s> <Plug>BufTabLine.Go(%d)', k, i)
    endfor
    unlet! keys i k
    ]])
  ]=],
})

use({
  "wellle/tmux-complete.vim",
  config = [=[vim.cmd([[
    let g:tmuxcomplete#trigger = ''
    inoremap <C-x><C-t> <Cmd>call completion#wrap('tmuxcomplete#complete')<CR>
    ]])
  ]=],
})

use("nelstrom/vim-visual-star-search")
use("tommcdo/vim-exchange")
use({
  "tommcdo/vim-lion",
  config = "vim.cmd([[let g:lion_squeeze_spaces = 1]])",
})

use("tpope/vim-abolish")
use("tpope/vim-apathy")
use("tpope/vim-endwise")
use("tpope/vim-obsession")
use("tpope/vim-repeat")
use("tpope/vim-scriptease")
use("tpope/vim-sleuth")
use("tpope/vim-speeddating")
use("tpope/vim-surround")
use({
  "tpope/vim-unimpaired",
  config = [[vim.cmd("let g:nremap = {'[a': '', ']a': ''}")]],
})

use({
  "tpope/vim-eunuch",
  config = "vim.cmd([[cnoremap w!! SudoWrite]])",
})

use({
  "tpope/vim-commentary",
  config = [=[vim.cmd([[
    augroup z-rc-commentary
      autocmd!
      autocmd FileType cmake setlocal commentstring=#%s
      autocmd FileType sql setlocal commentstring=--%s
      autocmd FileType c,typescript setlocal commentstring=//%s
    augroup END
    ]])
  ]=],
})

use("tpope/vim-fugitive")
use("tommcdo/vim-fubitive")
use({
  "tpope/vim-rhubarb",
  config = [=[vim.cmd([[
    nnoremap <silent> <leader>gs :Git<CR>
    nnoremap <silent> <leader>gc :Git commit<CR>
    nnoremap <silent> <leader>gw :Gwrite<CR>
    noremap  <silent> <leader>gb :GBrowse!<CR>
    ]])
  ]=],
})

use({
  "tpope/vim-dadbod",
  cmd = "DB",
  config = [=[vim.cmd([[
    command! DBSqueeze lua dbsqueeze.squeeze()
    augroup z-rc-dbsqueeze
      autocmd!
      autocmd BufReadPost *.dbout lua dbsqueeze.on_load(500)
    augroup END
    ]])
  ]=],
})

if need_to_compile then
  packer.compile()
end
