local api = vim.api
local autocmd = require("autocmd")
local z = require("z")

-- startup processes {{{
if vim.fn.has("vim_starting") == 1 then
  vim.env.VIMHOME = vim.fn.stdpath("config")

  -- turn off built-in plugins i don't want
  vim.g.loaded_netrwPlugin = "v153"
  vim.g.loaded_netrw = "v153"
  vim.g.loaded_tutor_mode_plugin = 1
  vim.g.loaded_2html_plugin = "vim7.4_v1"

  -- make sure my string extras are loaded and always available
  require("string_extras")
end
-- }}}

-- general settings {{{
vim.opt.colorcolumn = "+1"
vim.opt.completeopt:remove("preview")
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.fillchars = "fold:-"
vim.opt.fileformats = { "unix", "dos", "mac" }
vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"
vim.opt.formatoptions:append("n"):append("r"):append("o"):append("l")
vim.opt.gdefault = true
vim.opt.ignorecase = true
vim.opt.inccommand = "split"
vim.opt.lazyredraw = true
vim.opt.listchars = {
  space = "␣",
  eol = "¬",
  tab = "▸⁃",
  trail = "␣",
  precedes = "⤷",
  extends = "⤶",
}
vim.opt.matchpairs:append("<:>")
vim.opt.modeline = false
vim.opt.startofline = false
vim.opt.swapfile = false
vim.opt.wrap = false
vim.opt.omnifunc = "syntaxcomplete#Complete"
vim.opt.shiftround = true
vim.opt.shiftwidth = 4
vim.opt.shortmess:remove("F")
vim.opt.smartcase = true
vim.opt.spellfile = {
  vim.fn.expand("$VIMHOME/spell/custom.utf-8.add"),
  vim.fn.expand("$VIMHOME/spell/local.utf-8.add"),
}
vim.opt.softtabstop = 4
vim.opt.tags:prepend("./.git/tags;")
vim.opt.textwidth = 80
vim.opt.title = true
vim.opt.titlestring =
  [[nvim %{has_key(b:,'term_title')?b:term_title:len(expand('%'))>0?expand('%:t'):'[No name]'}]]
vim.opt.undofile = true
vim.opt.wildignore
  :append("node_modules/") -- javascript
  :append("package-lock.json")
  :append("*.min.js")
  :append("yarn.lock")
  :append("Cargo.lock") -- rust
  :append("*/target/*")
  :append(".git") -- git
  :append(".gitmodules")
  :append("*.swp") -- vim
  :append(".DS_Store") -- macos
vim.opt.wildignorecase = true
-- }}}

-- autocommands {{{
autocmd.augroup("filetypedetect", function(add)
  local filetypes = {
    ["*.c,*.h"] = "c",
    [".clang-format"] = "yaml",
    [".luacheckrc"] = "lua",
  }
  for pattern, ft in pairs(filetypes) do
    add("BufNewFile,BufReadPost", pattern, function()
      vim.bo.filetype = ft
    end)
  end
end)

autocmd.augroup("init-autocmds", function(add)
  -- always turn off paste when leaving insert mode (just in case)
  add("InsertLeave", "*", function()
    vim.o.paste = false
  end)

  -- quit even if dirvish or quickfix is open
  add("BufEnter", "*", function()
    if
      #api.nvim_list_wins() == 1
      and (vim.bo.buftype == "quickfix" or vim.bo.filetype == "dirvish")
    then
      if
        #vim.tbl_filter(function(b)
            return vim.bo[b].buflisted
          end, api.nvim_list_bufs())
          == 1
        or vim.bo.buftype == "quickfix"
      then
        vim.cmd("quit")
      else
        api.nvim_buf_delete(0, { force = true })
      end
    end
  end)

  -- see :help last-position-jump
  add("BufReadPost", "*", function()
    local mark = api.nvim_buf_get_mark(0, '"')
    if
      not vim.fn.expand("%"):match("COMMIT_EDITMSG")
      and mark[1] > 1
      and mark[1] <= api.nvim_buf_line_count(0)
    then
      api.nvim_win_set_cursor(0, mark)
    end
  end)

  -- don't move my position when switching buffers
  add("BufWinLeave", "*", function()
    vim.b.winview = vim.fn.winsaveview()
  end)
  add("BufWinEnter", "*", function()
    if vim.b.winview then
      vim.fn.winrestview(vim.b.winview)
      vim.b.winview = nil
    end
  end)

  -- terminal settings
  add("TermOpen", "*", function()
    vim.opt_local.number = false
    vim.opt_local.statusline = "[terminal] %{b:term_title}"
  end)

  -- reload config files on saving
  add("BufWritePost", vim.env.MYVIMRC, function()
    vim.cmd("source $MYVIMRC")
  end, {
    nested = true,
  })
  add("BufWritePost", vim.env.VIMHOME .. "/{plugin,lua}/*.lua", function()
    vim.cmd("source " .. vim.fn.expand("<afile>"))
  end)
  add("BufWritePost", vim.env.VIMHOME .. "/colors/*.vim", function()
    vim.cmd("colorscheme " .. vim.fn.expand("<afile>:t:r"))
  end)

  -- set foldmethod for this file
  add("BufReadPost", vim.env.MYVIMRC, function()
    vim.cmd("setlocal foldmethod=marker")
  end)
end)
-- }}}

-- keymaps and commands {{{
local function noremap(mode, left, right, opts)
  opts = opts or {}
  opts.noremap = true
  api.nvim_set_keymap(mode, left, right, opts)
end

-- abbreviations
vim.cmd([[iabbrev shrug! ¯\_(ツ)_/¯]])

autocmd.augroup("init-autocmds-abbreviations", function(add)
  add("FileType", "javascript,typescript", function()
    vim.cmd("iabbrev <buffer> != !==")
    vim.cmd("iabbrev <buffer> == ===")
  end, {
    unique = true,
  })
  add("FileType", "javascript,typescript,lua,vim,zsh", function()
    vim.cmd("iabbrev <buffer> fn! function")
  end, {
    unique = true,
  })
end)

-- typos
vim.cmd([[
  command! -bang -nargs=1 -complete=file E e<bang> <args>
  command! -bang -nargs=1 -complete=help H h<bang> <args>
  command! -bang Q q<bang>
  command! -bang Qa qa<bang>
  command! -bang QA qa<bang>
  command! -bang Wq wq<bang>
  command! -bang WQ wq<bang>
  command! -bang BD Bd<bang>
]])

-- fit current window to contents
vim.cmd("command! Fit silent! execute 'resize' line('$')")

-- select last-pasted text
noremap("n", "gV", "`[v`]")

-- i don't need an escape key
noremap("i", "jk", "<Esc>")
noremap("t", "jk", [[<C-\><C-n>]])

-- current directory in command-line
noremap("c", "%%", [[fnameescape(expand("%:p:h")) .. "/"]], { expr = true })

-- write then delete buffer; akin to wq
noremap("c", "wbd", "Wbd")
vim.cmd("command! -bang Wbd w<bang> | Bd<bang>")

-- search bindings
noremap("n", "*", "*N")
noremap("n", "#", "#N")
noremap("n", "<Space>", "<Cmd>nohlsearch<CR>", { silent = true })

-- close all floating windows
_G.close_floating_windows = function()
  for _, id in ipairs(api.nvim_list_wins()) do
    if api.nvim_win_get_config(id).relative ~= "" then
      api.nvim_win_close(id, true)
    end
  end
end
vim.cmd([[command! CloseFloatingWindows silent! lua close_floating_windows()]])
noremap("n", "<Esc>", "<Cmd>CloseFloatingWindows<CR>")

-- resize windows
noremap("n", "<C-Left>", "<C-W><")
noremap("n", "<C-Right>", "<C-W>>")
noremap("n", "<C-Up>", "<C-W>+")
noremap("n", "<C-Down>", "<C-W>-")

-- switch windows
noremap("n", "<C-h>", "<C-W>h")
noremap("n", "<C-l>", "<C-W>l")
noremap("n", "<C-k>", "<C-W>k")
noremap("n", "<C-j>", "<C-W>j")

-- redraw screen
noremap("n", "g<C-L>", "<Cmd>mode<CR>")

-- open terminal split
noremap("n", "<C-W><C-t>", "<Cmd>botright vsp +term<CR>:startinsert<CR>")
noremap("n", "<C-W>T", "<Cmd>botright sp +term<CR>:startinsert<CR>")
noremap("n", "<C-W>t", "<Cmd>belowright 20sp +term<CR>:startinsert<CR>")

-- un-dos files with ^M line endings
vim.cmd([[command! Undos e ++ff=unix | %s/\r//g]])

-- set indentation
vim.cmd(
  "command! -bar -nargs=1 SetIndent setlocal softtabstop=<args> shiftwidth=<args>"
)

-- move by visual lines
noremap("n", "j", "gj")
noremap("n", "gj", "j")
noremap("n", "k", "gk")
noremap("n", "gk", "k")
noremap("n", "0", "&wrap ? 'g0' : '0'", { expr = true })
noremap("n", "g0", "&wrap ? '0' : 'g0'", { expr = true })
noremap("n", "$", "&wrap ? 'g$' : '$'", { expr = true })
noremap("n", "g$", "&wrap ? '$' : 'g$'", { expr = true })

-- maintain visual mode for indenting
noremap("v", "<", "<gv")
noremap("v", ">", ">gv")

-- maintain visual mode for increment/decrement
noremap("v", "<C-a>", "<C-a>gv")
noremap("v", "<C-x>", "<C-x>gv")

-- copy entire buffer to system clipboard
noremap("n", "<leader>a", ":%yank +<CR>", { silent = true })

-- insert a single space
noremap("n", "<leader><Space>", "i<Space><Esc>")

-- arrows
_G.arrow = function(fat)
  local before = " "
  if z.char_before_cursor():is_empty() then
    before = ""
  end
  local arrow = "->"
  if fat then
    arrow = "=>"
  end
  local line = api.nvim_get_current_line()
  local col = api.nvim_win_get_cursor(0)[2]
  local after = api.nvim_replace_termcodes("<Right>", true, false, true)
  if #line <= col or not line:sub(col + 1, col + 1):is_empty() then
    after = " "
  end
  return before .. arrow .. after
end
api.nvim_set_keymap("i", "<C-j>", "v:lua.arrow(v:false)", { expr = true })
api.nvim_set_keymap("i", "<C-l>", "v:lua.arrow(v:true)", { expr = true })
autocmd.augroup("init-autocmds-arrows", function(add)
  add("FileType", "c", function()
    api.nvim_buf_set_keymap(0, "i", "<C-j>", "->", {})
  end)
  add("FileType", "vim", function()
    vim.b.arrow_fn = function()
      if z.char_before_cursor() == "{" then
        return "-> "
      end
      return _G.arrow(false)
    end
    api.nvim_buf_set_keymap(0, "i", "<C-j>", "b:arrow_fn()", { expr = true })
  end)
end)

-- quickfix
_G.quickfix_toggle = function()
  local cr = api.nvim_replace_termcodes("<CR>", true, false, true)
  if
    #vim.tbl_filter(function(b)
      return vim.bo[b].filetype == "qf"
    end, api.nvim_list_bufs()) > 0
  then
    return ":cclose" .. cr
  end
  return ":copen" .. cr
end
noremap(
  "n",
  "<leader>q",
  "v:lua.quickfix_toggle()",
  { silent = true, expr = true }
)
autocmd.add("FileType", "qf", function()
  api.nvim_buf_set_keymap(
    0,
    "n",
    "<C-c>",
    ":cclose<CR>",
    { noremap = true, silent = true }
  )
  api.nvim_buf_set_keymap(
    0,
    "n",
    "q",
    ":cclose<CR>",
    { noremap = true, silent = true }
  )
  vim.opt_local.wrap = false
end, {
  augroup = "init-autocmds-quickfix",
})

-- local settings
local function source_local_vimrc(force)
  local is_fugitive = ("^fugitive://"):match(vim.fn.expand("<afile>"))
  local abuf = tonumber(vim.fn.expand("<abuf>"))
  if
    not force
    and (
      is_fugitive
      or vim.tbl_contains({ "help", "nofile" }, vim.bo[abuf].buftype)
    )
  then
    return
  end
  -- apply settings from lowest dir to highest, so most specific are applied last
  for _, vimrc in ipairs(
    z.tbl_reverse(
      vim.fn.findfile(".vimrc.lua", vim.fn.expand("<afile>:p:h") .. ";", -1)
    )
  ) do
    vim.cmd("silent! source " .. vimrc)
  end
end
autocmd.augroup("init-autocmds-local-vimrc", function(add)
  add("BufNewFile,BufReadPost", "*", function()
    source_local_vimrc(false)
  end, {
    nested = true,
  })
  add("VimEnter", "*", function()
    source_local_vimrc(true)
  end, {
    nested = true,
  })
end)

-- make directories if they don't exist before writing file
autocmd.add("BufWritePre", "*", function()
  local dir = vim.fn.expand("%:p:h")
  if not vim.loop.fs_stat(dir) then
    if
      vim.fn.confirm("Directory does not exist. Create?", "&Yes\n&No", 2) == 1
    then
      vim.fn.mkdir(dir, "p")
    end
  end
end, {
  augroup = "init-autocmds-mkdir-on-write",
})
-- }}}

-- colors and appearance {{{
vim.cmd("colorscheme copper")

_G.statusline_filename = function()
  if #vim.fn.expand("%") > 0 then
    return vim.fn.expand("%:~")
  end
  return string.format("[cwd: %s]", vim.fn.fnamemodify(vim.loop.cwd(), ":~"))
end

vim.opt.statusline = "[%n] %{v:lua.statusline_filename()}%<"
  .. "%( %{get(b:, 'gitsigns_status', '')}%)"
  .. "%( %h%)%( %m%)%( %r%)"
  .. "%{&ff != 'unix' ? ' [' .. &ff .. ']' : ''}"
  .. "%{len(&fenc) && &fenc != 'utf-8' ? ' [' .. &fenc .. ']' : ''}"
  .. "%="
  .. "%{&wrap ? '[wrap] ' : ''}"
  .. "%{&paste ? '[paste] ' : ''}"
  .. "%(%{ObsessionStatus()} %)"
  .. "  %l,%c%V%6P"
-- }}}
