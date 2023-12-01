local utils = require("utils")

-- startup processes
if vim.fn.has("vim_starting") == 1 then
  -- turn off built-in plugins i don't want
  vim.g.loaded_netrwPlugin = "v153"
  vim.g.loaded_netrw = "v153"
  vim.g.loaded_tutor_mode_plugin = 1
  vim.g.loaded_2html_plugin = "vim7.4_v1"

  -- make sure my string extras are loaded and always available
  require("string-extras")
end

-- general settings
vim.opt.colorcolumn = "+1"
vim.opt.completeopt:remove("preview")
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.fillchars = { fold = "-" }
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
  -- javascript
  + "node_modules/"
  + "package-lock.json"
  + "yarn.lock"
  -- rust
  + "Cargo.lock"
  + "*/target/*"
  -- git
  + ".git"
  + ".gitmodules"
  -- macos
  + ".DS_Store"
vim.opt.wildignorecase = true

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
  group = vim.api.nvim_create_augroup("init-autocmds", {}),
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
  group = vim.api.nvim_create_augroup("init-autocmds", { clear = false }),
})

-- terminal settings
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.statusline = "[terminal] %{b:term_title}"
  end,
  group = vim.api.nvim_create_augroup("init-autocmds", { clear = false }),
})

-- reload config files on saving
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {
    vim.env.MYVIMRC,
    vim.fn.stdpath("config") .. "/{plugin,lua,colors}/*.lua",
  },
  callback = function(args)
    vim.cmd.source(args.file)
  end,
  group = vim.api.nvim_create_augroup("init-autocmds", { clear = false }),
  nested = true,
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

-- search bindings
vim.keymap.set("n", "*", "*N")
vim.keymap.set("n", "#", "#N")
vim.keymap.set("n", "<Space>", "<Cmd>nohlsearch<CR>", { silent = true })
vim.keymap.set(
  "x",
  "*",
  [[:<C-u>lua require("utils").v_star_search_set("/")<CR>/<C-r>=@/<CR><CR>N]]
)
vim.keymap.set(
  "x",
  "#",
  [[:<C-u>lua require("utils").v_star_search_set("?")<CR>?<C-r>=@/<CR><CR>N]]
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
---@param fat boolean
local function arrow(fat)
  local before = utils.char_before_cursor():is_empty() and "" or " "
  local ret = fat and "=>" or "->"
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

-- quickfix
---@param vertical boolean
local function quickfix_toggle(vertical)
  if
    utils.tbl_any(function(b)
      return vim.bo[b].filetype == "qf" and vim.bo[b].buflisted
    end, vim.api.nvim_list_bufs())
  then
    vim.cmd.cclose()
    return
  end
  vim.cmd.copen(vertical and {
    mods = { split = "topleft", vertical = true },
    range = { math.floor(vim.o.columns / 3) },
  } or { mods = { split = "botright" } })
end
vim.keymap.set("n", "<leader>q", quickfix_toggle, { silent = true })
vim.keymap.set("n", "<leader>Q", function()
  quickfix_toggle(true)
end, { silent = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    for _, key in ipairs({ "q", "<C-c>" }) do
      vim.keymap.set("n", key, vim.cmd.cclose, { buffer = true, silent = true })
    end
    vim.opt_local.wrap = false
  end,
  group = vim.api.nvim_create_augroup("init-autocmds-quickfix", {}),
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

vim.cmd.colorscheme("copper")

-- plugins in `/lua`
-- these have to export functions so need to be somewhere they can be found by
-- `require()`, otherwise they could live in `/plugin` and be sourced
-- automatically.
require("commandline").init()
require("completion").init()
require("statusline").init()
require("test-runner").init()
