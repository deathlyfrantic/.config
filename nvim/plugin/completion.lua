local api = vim.api
local z = require("z")

local function findstart()
  local row = api.nvim_win_get_cursor(0)[1]
  local pos = vim.fn.searchpos([[\s]], "bn")
  -- cursor is on same line as found whitespace
  if pos[1] == row then
    return pos[2]
  end
  return 0
end

local function tab(fwd)
  if vim.fn.pumvisible() > 0 then
    if fwd then
      return "<C-n>"
    end
    return "<C-p>"
  elseif z.char_before_cursor():match("[A-Za-z0-9_]") then
    return "<C-p>"
  end
  return "<Tab>"
end

local function undouble()
  -- stolen from Damian Conway
  -- https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/003fb8e06e1b8d321a129869a62eaa702cea6dc9/.vimrc#L1372-L1381
  local row, col = unpack(api.nvim_win_get_cursor(0))
  local line = api.nvim_get_current_line()
  local new_line =
    vim.fn.substitute(line, [[\(\.\?\k\+\)\%]] .. col + 1 .. [[c\zs\1]], "", "")
  api.nvim_buf_set_lines(0, row - 1, row, true, { new_line })
end

local function wrap(f)
  if type(f) == "string" then
    -- assuming this is the name of a viml function
    f = vim.fn[f]
  end
  local col = api.nvim_win_get_cursor(0)[2]
  local start = f(true, 0)
  local line = api.nvim_get_current_line()
  local base = line:sub(start, col + 1)
  vim.fn.complete(start + 1, f(false, base))
end

local function gitcommit()
  wrap(function(fs, base)
    if fs then
      return findstart()
    end
    local cmd = "git log --oneline --no-merges"
    if #base > 0 then
      cmd = cmd .. " --grep='" .. base .. "'"
    else
      cmd = cmd .. " -n 5000"
    end
    local commits = vim.split(
      io.popen(cmd):read("*all"),
      "\n",
      { plain = true, trimempty = true }
    )
    table.sort(commits, function(a, b)
      -- chop off the commit hash when sorting
      return a:gsub("^%w+%s+", "") < b:gsub("^%w+%s", "")
    end)
    return vim.tbl_map(function(commit)
      return {
        abbr = commit,
        word = vim.split(commit, " ", { plain = true, trimempty = true })[1],
      }
    end, commits)
  end)
end

_G.completion = {
  findstart = findstart,
  wrap = wrap,
}

api.nvim_create_autocmd("CompleteDone", {
  pattern = "*",
  callback = undouble,
  group = api.nvim_create_augroup("completion-undouble", {}),
})

vim.keymap.set("i", "<Tab>", function()
  return tab(true)
end, { silent = true, expr = true })
vim.keymap.set("i", "<S-Tab>", function()
  return tab(false)
end, { silent = true, expr = true })
vim.keymap.set("i", "<C-x><C-g>", gitcommit, { silent = true })
