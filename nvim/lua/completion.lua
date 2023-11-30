local utils = require("utils")

local M = {}

---@return integer
local function findstart()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local pos = vim.fn.searchpos([[\s]], "bn")
  -- cursor is on same line as found whitespace
  return pos[1] == row and pos[2] or 0
end

---@param fwd boolean
---@return string
local function tab(fwd)
  if vim.fn.pumvisible() > 0 then
    return fwd and "<C-n>" or "<C-p>"
  elseif utils.char_before_cursor():match("[A-Za-z0-9_]") then
    return "<C-p>"
  end
  return "<Tab>"
end

-- if completing in the middle of a word, remove the completed portion already
-- on the line, i.e. completing "foobar" with cursor position foo|bar results in
-- "foobar" instead of "foobarbar".
-- stolen from Damian Conway
-- https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/003fb8e06e1b8d321a129869a62eaa702cea6dc9/.vimrc#L1372-L1381
local function undouble()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local new_line =
    vim.fn.substitute(line, [[\(\.\?\k\+\)\%]] .. col + 1 .. [[c\zs\1]], "", "")
  vim.api.nvim_buf_set_lines(0, row - 1, row, true, { new_line })
end

-- "wrap" a completion function so it can be triggered arbitrarily
---@param f string | function
function M.wrap(f)
  if type(f) == "string" then
    -- assuming this is the name of a viml function
    f = vim.fn[f]
  end
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local start = f(true, 0)
  local line = vim.api.nvim_get_current_line()
  local base = line:sub(start, col + 1)
  vim.fn.complete(start + 1, f(false, base))
end

local function gitcommit()
  M.wrap(function(fs, base)
    if fs then
      return findstart()
    end
    local cmd = "git log --oneline --no-merges"
    if #base > 0 then
      cmd = cmd .. " --grep='" .. base .. "'"
    else
      cmd = cmd .. " -n 5000"
    end
    local commits =
      io.popen(cmd):read("*all"):split("\n", { plain = true, trimempty = true })
    table.sort(commits, function(a, b)
      -- chop off the commit hash when sorting
      return a:gsub("^%w+%s+", "") < b:gsub("^%w+%s", "")
    end)
    return vim.tbl_map(function(commit)
      return {
        abbr = commit,
        word = commit:split(" ", { plain = true, trimempty = true })[1],
      }
    end, commits)
  end)
end

function M.init()
  vim.api.nvim_create_autocmd("CompleteDone", {
    pattern = "*",
    callback = undouble,
    group = vim.api.nvim_create_augroup("completion-undouble", {}),
  })
  vim.keymap.set("i", "<Tab>", function()
    return tab(true)
  end, { silent = true, expr = true })
  vim.keymap.set("i", "<S-Tab>", function()
    return tab(false)
  end, { silent = true, expr = true })
  vim.keymap.set("i", "<C-x><C-g>", gitcommit, { silent = true })
end

return M
