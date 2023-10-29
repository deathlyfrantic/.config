local z = require("z")

-- startup processes {{{
if vim.fn.has("vim_starting") == 1 then
  -- turn off built-in plugins i don't want
  vim.g.loaded_netrwPlugin = "v153"
  vim.g.loaded_netrw = "v153"
  vim.g.loaded_tutor_mode_plugin = 1
  vim.g.loaded_2html_plugin = "vim7.4_v1"

  -- make sure my string extras are loaded and always available
  require("z.string-extras")
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
vim.opt.formatoptions = vim.opt.formatoptions + "n" + "r" + "o" + "l"
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
vim.opt.mouse = ""
vim.opt.startofline = false
vim.opt.swapfile = false
vim.opt.wrap = false
vim.opt.omnifunc = "syntaxcomplete#Complete"
vim.opt.shiftround = true
vim.opt.shiftwidth = 4
vim.opt.smartcase = true
vim.opt.spellfile = {
  vim.fn.stdpath("config") .. "/spell/custom.utf-8.add",
  vim.fn.stdpath("config") .. "/spell/local.utf-8.add",
}
vim.opt.softtabstop = 4
vim.opt.tags:prepend("./.git/tags;")
vim.opt.textwidth = 80
vim.opt.title = true
vim.opt.titlestring =
  [[nvim %{has_key(b:,'term_title')?b:term_title:len(expand('%'))>0?expand('%:t'):'[No name]'}]]
vim.opt.undofile = true
vim.opt.wildignore = vim.opt.wildignore
  + "node_modules/" -- javascript
  + "package-lock.json"
  + "yarn.lock"
  + "Cargo.lock" -- rust
  + "*/target/*"
  + ".git" -- git
  + ".gitmodules"
  + "*.swp" -- vim
  + ".DS_Store" -- macos
vim.opt.wildignorecase = true
-- }}}

-- autocommands {{{
local group = vim.api.nvim_create_augroup("init-autocmds", {})
-- quit even if dirvish or quickfix is open
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    if
      #vim.api.nvim_list_wins() == 1
      and (vim.bo.buftype == "quickfix" or vim.bo.filetype == "dirvish")
    then
      if
        #vim.tbl_filter(function(b)
            return vim.bo[b].buflisted
          end, vim.api.nvim_list_bufs())
          == 1
        or vim.bo.buftype == "quickfix"
      then
        vim.cmd.quit()
      else
        vim.api.nvim_buf_delete(0, { force = true })
      end
    end
  end,
  group = group,
})

-- see :help last-position-jump
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if
      not vim.api.nvim_buf_get_name(0):match("COMMIT_EDITMSG")
      and mark[1] > 1
      and mark[1] <= vim.api.nvim_buf_line_count(0)
    then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
  group = group,
})

-- don't move my position when switching buffers
-- i don't know that this is actually necessary. the commit in which it was
-- added has a shitty message so i don't know why i did it.
vim.api.nvim_create_autocmd("BufWinLeave", {
  pattern = "*",
  callback = function()
    vim.b.winview = vim.fn.winsaveview()
  end,
  group = group,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*",
  callback = function()
    if vim.b.winview then
      vim.fn.winrestview(vim.b.winview)
      vim.b.winview = nil
    end
  end,
  group = group,
})

-- terminal settings
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.statusline = "[terminal] %{b:term_title}"
  end,
  group = group,
})

-- reload config files on saving
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = vim.env.MYVIMRC,
  callback = function()
    vim.cmd.source("$MYVIMRC")
  end,
  group = group,
  nested = true,
})
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = vim.fn.stdpath("config") .. "/{plugin,lua}/*.lua",
  callback = function(args)
    vim.cmd.source(args.file)
  end,
  group = group,
})
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = vim.fn.stdpath("config") .. "/colors/*.lua",
  callback = function(args)
    vim.cmd.colorscheme(vim.fs.basename(args.file):match("(.*)%."))
  end,
  group = group,
})

-- set foldmethod for this file
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = vim.env.MYVIMRC,
  callback = function()
    vim.opt_local.foldmethod = "marker"
  end,
  group = group,
})
-- }}}

-- keymaps and commands {{{
-- abbreviations
vim.cmd.iabbrev([[shrug! ¯\_(ツ)_/¯]])

group = vim.api.nvim_create_augroup("init-autocmds-abbreviations", {})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript" },
  callback = function()
    vim.cmd.iabbrev("<buffer> != !==")
    vim.cmd.iabbrev("<buffer> == ===")
  end,
  group = group,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "lua", "vim", "zsh" },
  callback = function()
    vim.cmd.iabbrev("<buffer> fn! function")
  end,
  group = group,
})

-- typos
vim.api.nvim_create_user_command(
  "E",
  "e<bang> <args>",
  { bang = true, complete = "file", nargs = 1 }
)
vim.api.nvim_create_user_command(
  "H",
  "h<bang> <args>",
  { bang = true, complete = "help", nargs = 1 }
)
vim.api.nvim_create_user_command("Q", "q<bang>", { bang = true })
vim.api.nvim_create_user_command("Qa", "qa<bang>", { bang = true })
vim.api.nvim_create_user_command("QA", "qa<bang>", { bang = true })
vim.api.nvim_create_user_command("Wq", "wq<bang>", { bang = true })
vim.api.nvim_create_user_command("WQ", "wq<bang>", { bang = true })
vim.api.nvim_create_user_command("BD", "Bd<bang>", { bang = true })

-- fit current window to contents
vim.api.nvim_create_user_command(
  "Fit",
  "silent! execute 'resize' line('$')",
  {}
)

-- select last-pasted text
vim.keymap.set("n", "gV", "`[v`]")

-- i don't need an escape key
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("t", "jk", [[<C-\><C-n>]])

-- current directory in command-line
vim.keymap.set("c", "%%", function()
  return vim.fs.dirname(vim.api.nvim_buf_get_name(0)) .. "/"
end, { expr = true })

-- write then delete buffer; akin to wq
vim.keymap.set("c", "wbd", "Wbd")
vim.api.nvim_create_user_command("Wbd", "w<bang> | Bd<bang>", { bang = true })

-- search bindings
vim.keymap.set("n", "*", "*N")
vim.keymap.set("n", "#", "#N")
vim.keymap.set("n", "<Space>", "<Cmd>nohlsearch<CR>", { silent = true })
vim.keymap.set(
  "x",
  "*",
  [[:<C-u>lua require("z").v_star_search_set("/")<CR>/<C-r>=@/<CR><CR>N]]
)
vim.keymap.set(
  "x",
  "#",
  [[:<C-u>lua require("z").v_star_search_set("?")<CR>?<C-r>=@/<CR><CR>N]]
)

-- close all floating windows
local function close_floating_windows()
  for _, id in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(id).relative ~= "" then
      vim.api.nvim_win_close(id, true)
    end
  end
end
vim.api.nvim_create_user_command(
  "CloseFloatingWindows",
  close_floating_windows,
  {}
)
vim.keymap.set("n", "<Esc>", close_floating_windows)

-- resize windows
vim.keymap.set("n", "<C-Left>", "<C-W><")
vim.keymap.set("n", "<C-Right>", "<C-W>>")
vim.keymap.set("n", "<C-Up>", "<C-W>+")
vim.keymap.set("n", "<C-Down>", "<C-W>-")

-- switch windows
vim.keymap.set("n", "<C-h>", "<C-W>h")
vim.keymap.set("n", "<C-l>", "<C-W>l")
vim.keymap.set("n", "<C-k>", "<C-W>k")
vim.keymap.set("n", "<C-j>", "<C-W>j")

-- redraw screen
vim.keymap.set("n", "g<C-L>", "<Cmd>mode<CR>")

-- open terminal split
vim.keymap.set("n", "<C-W><C-t>", "<Cmd>botright vsp +term<CR>:startinsert<CR>")
vim.keymap.set("n", "<C-W>T", "<Cmd>botright sp +term<CR>:startinsert<CR>")
vim.keymap.set("n", "<C-W>t", "<Cmd>belowright 20sp +term<CR>:startinsert<CR>")

-- un-dos files with ^M line endings
vim.api.nvim_create_user_command("Undos", [[e ++ff=unix | %s/\r//g]], {})

-- set indentation
vim.api.nvim_create_user_command(
  "SetIndent",
  "setlocal softtabstop=<args> shiftwidth=<args>",
  { bar = true, nargs = 1 }
)

-- move by visual lines
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "gj", "j")
vim.keymap.set("n", "k", "gk")
vim.keymap.set("n", "gk", "k")
vim.keymap.set("n", "0", "&wrap ? 'g0' : '0'", { expr = true })
vim.keymap.set("n", "g0", "&wrap ? '0' : 'g0'", { expr = true })
vim.keymap.set("n", "$", "&wrap ? 'g$' : '$'", { expr = true })
vim.keymap.set("n", "g$", "&wrap ? '$' : 'g$'", { expr = true })

-- maintain visual mode for indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- maintain visual mode for increment/decrement
vim.keymap.set("v", "<C-a>", "<C-a>gv")
vim.keymap.set("v", "<C-x>", "<C-x>gv")

-- copy entire buffer to system clipboard
vim.keymap.set("n", "<leader>a", ":%yank +<CR>", { silent = true })

-- insert a single space
vim.keymap.set("n", "<leader><Space>", "i<Space><Esc>")

-- arrows
local function arrow(fat)
  local before = " "
  if z.char_before_cursor():is_empty() then
    before = ""
  end
  local ret = "->"
  if fat then
    ret = "=>"
  end
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local after = "<Right>"
  if #line <= col or not line:sub(col + 1, col + 1):is_empty() then
    after = " "
  end
  return before .. ret .. after
end
vim.keymap.set("i", "<C-j>", function()
  return arrow(false)
end, { expr = true })
vim.keymap.set("i", "<C-l>", function()
  return arrow(true)
end, { expr = true })
group = vim.api.nvim_create_augroup("init-autocmds-arrows", {})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "c",
  callback = function()
    vim.keymap.set("i", "<C-j>", "->", { buffer = true })
  end,
  group = group,
})

-- quickfix
local function quickfix_toggle(vertical)
  if
    #vim.tbl_filter(function(b)
      return vim.bo[b].filetype == "qf" and vim.bo[b].buflisted
    end, vim.api.nvim_list_bufs()) > 0
  then
    return ":cclose<CR>"
  end
  if vertical then
    return ":topleft vertical copen " .. math.floor(vim.o.columns / 3) .. "<CR>"
  end
  return ":botright copen<CR>"
end
vim.keymap.set(
  "n",
  "<leader>q",
  quickfix_toggle,
  { silent = true, expr = true }
)
vim.keymap.set("n", "<leader>Q", function()
  return quickfix_toggle(true)
end, { silent = true, expr = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set(
      "n",
      "<C-c>",
      ":cclose<CR>",
      { buffer = true, silent = true }
    )
    vim.keymap.set("n", "q", ":cclose<CR>", { buffer = true, silent = true })
    vim.opt_local.wrap = false
  end,
  group = vim.api.nvim_create_augroup("init-autocmds-quickfix", {}),
})

-- local settings
local function source_local_vimrc(file, buf, force)
  if
    not force
    and (
      file:starts_with("fugitive://")
      or vim.tbl_contains({ "help", "nofile" }, vim.bo[tonumber(buf)].buftype)
    )
  then
    return
  end
  -- apply settings from lowest dir to highest, so most specific are applied last
  for _, vimrc in
    ipairs(
      z.tbl_reverse(
        vim.fn.findfile(
          ".vimrc.lua",
          vim.fs.dirname(vim.fs.normalize(file)) .. ";",
          -1
        )
      )
    )
  do
    vim.cmd.source({
      args = { vimrc },
      mods = { emsg_silent = true, silent = true },
    })
  end
end
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost", "VimEnter" }, {
  pattern = "*",
  callback = function(args)
    source_local_vimrc(args.match, args.buf, args.event == "VimEnter")
  end,
  nested = true,
  group = vim.api.nvim_create_augroup("init-autocmds-local-vimrc", {}),
})

-- make directories if they don't exist before writing file
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    local dir = vim.fs.dirname(args.file)
    if not vim.loop.fs_stat(dir) then
      if
        vim.fn.confirm("Directory does not exist. Create?", "&Yes\n&No", 2) == 1
      then
        vim.fn.mkdir(dir, "p")
      end
    end
  end,
  group = vim.api.nvim_create_augroup("init-autocmds-mkdir-on-write", {}),
})
-- }}}

-- colors and appearance {{{
vim.cmd.colorscheme("copper")

vim.opt.statusline = "[%n] %{v:lua.require('z.statusline').filename()}%<"
  .. "%( %{get(b:, 'gitsigns_status', '')}%)"
  .. "%( %h%)%( %m%)%( %r%)"
  .. "%{&ff != 'unix' ? ' [' .. &ff .. ']' : ''}"
  .. "%{len(&fenc) && &fenc != 'utf-8' ? ' [' .. &fenc .. ']' : ''}"
  .. "%="
  .. "%{&wrap ? '[wrap] ' : ''}"
  .. "%(%{ObsessionStatus()} %)"
  .. "  %l,%c%V%6P"
-- }}}
