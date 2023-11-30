local utils = require("utils")

local pairs = { ["("] = ")", ["["] = "]", ["{"] = "}" }
local closers = { [")"] = "(", ["]"] = "[", ["}"] = "{" }
-- we only look at these patterns if the line ends in an opening pair so we
-- don't have to include the opening pair in the patterns
local semi_lines = {
  javascript = {
    "%s+=%s+",
    "^return%s+",
    "^[%w%.]+%($", -- foo.bar(
    "^await%s+[%w%.]+%($", -- await foo.bar(
  },
  rust = {
    "%s+=%s+",
    "^return%s+",
  },
  c = {
    "%s+=%s+",
    "^return%s+",
    "struct%s+.*{$",
    "enum%s+.*{",
  },
}
semi_lines.typescript = semi_lines.javascript

---@param num integer
---@return string
local function getline(num)
  return vim.api.nvim_buf_get_lines(0, num - 1, num, false)[1] or ""
end

---@param state State
---@return string
local function semi(state)
  if not semi_lines[state.ft] then
    return ""
  end
  if
    utils.tbl_any(function(pat)
      return state.trimmed:match(pat)
    end, semi_lines[state.ft])
  then
    return ";"
  end
  return ""
end

---@param line string
---@return integer
local function indent(line)
  return #line:match("^%s*")
end

---@param line integer
---@param col integer
---@return boolean
local function in_string(line, col)
  return utils.highlight_at_pos_contains("string", { line, col })
end

---@param stack string[]
---@param char string
local function remove_last(stack, char)
  for i = #stack, 1, -1 do
    if stack[i] == char then
      table.remove(stack, i)
      return
    end
  end
end

---@param state State
---@param ends string[]
---@return boolean
local function should_close(state, ends)
  local start = table.concat(
    vim.tbl_map(function(c)
      return closers[c]
    end, ends),
    ""
  )
  local ending = table.concat(ends, ""):reverse()
  local match = vim.fn.searchpair(start, "", ending, "Wn")
  return not (match > 0 and indent(getline(match)) == indent(state.line))
end

---@return string
local function enter()
  ---@class State
  ---@field ft string Filetype of buffer
  ---@field cursor integer[] Cursor position within window
  ---@field line string Contents of current line
  ---@field linenr integer Line number of the cursor
  ---@field col integer Column number of the cursor
  ---@field trimmed string Trimmed version of the current line's contents
  local state = {
    ft = vim.bo.filetype,
    cursor = vim.api.nvim_win_get_cursor(0),
    line = vim.api.nvim_get_current_line(),
  }
  state.linenr = state.cursor[1]
  state.col = state.cursor[2]
  state.trimmed = state.line:trim()
  if
    state.col < #state.line:gsub("%s*$", "")
    or not pairs[state.trimmed:sub(-1, -1)]
  then
    -- don't do anything if cursor is not at the end of a line,
    -- or if the (trimmed) line doesn't end with a left pair item
    return "<CR>"
  end
  local stack = {}
  for i, c in state.line:chars() do
    if pairs[c] and not in_string(state.linenr, i) then
      table.insert(stack, pairs[c])
    elseif closers[c] and not in_string(state.linenr, i) then
      remove_last(stack, c)
    end
  end
  local slash = ""
  if state.ft == "vim" then
    slash = "\\ "
  end
  if #stack > 0 and should_close(state, stack) then
    return "<CR>"
      .. slash
      .. table.concat(stack, ""):reverse()
      .. semi(state)
      .. "<C-o>O"
      .. slash
  end
  return "<CR>"
end

vim.keymap.set("i", "<Plug>autocloseCR", enter, { expr = true })
vim.keymap.set("i", "<Enter>", "<Plug>autocloseCR", { remap = true })
