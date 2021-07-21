local api = vim.api
local z = require("z")

local key_cr = api.nvim_replace_termcodes("<Enter>", true, false, true)
local key_ctrl_o = api.nvim_replace_termcodes("<C-o>", true, false, true)
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

local function getline(num)
  return api.nvim_buf_get_lines(0, num - 1, num, false)[1] or ""
end

local function semi(state)
  if semi_lines[state.ft] == nil then
    return ""
  end
  if
    z.any(semi_lines[state.ft], function(pat)
      return state.trimmed:match(pat)
    end)
  then
    return ";"
  end
  return ""
end

local function indent(line)
  return #line:match("^%s*")
end

local function in_string(line, col)
  return z.any(vim.fn.synstack(line, col), function(id)
    return vim.fn.synIDattr(vim.fn.synIDtrans(id), "name"):match("[Ss][Tt][Rr][Ii][Nn][Gg]")
  end)
end

local function remove_last(stack, char)
  for i = #stack, 1, -1 do
    if stack[i] == char then
      table.remove(stack, i)
      return
    end
  end
end

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

local function enter()
  local state = {
    ft = vim.bo.filetype,
    cursor = api.nvim_win_get_cursor(0),
    line = api.nvim_get_current_line(),
  }
  state.linenr = state.cursor[1]
  state.col = state.cursor[2]
  state.trimmed = state.line:trim()
  if
    state.col < #state.line:gsub("%s*$", "")
    or pairs[state.trimmed:sub(-1, -1)] == nil
  then
    -- don't do anything if cursor is not at the end of a line,
    -- or if the (trimmed) line doesn't end with a left pair item
    return key_cr
  end
  local stack = {}
  for i, c in state.line:chars() do
    if not in_string(state.linenr, i) then
      if pairs[c] ~= nil then
        table.insert(stack, pairs[c])
      elseif closers[c] ~= nil then
        remove_last(stack, c)
      end
    end
  end
  local slash = ""
  if state.ft == "vim" then
    slash = "\\ "
  end
  if #stack > 0 and should_close(state, stack) then
    return key_cr
      .. slash
      .. table.concat(stack, ""):reverse()
      .. semi(state)
      .. key_ctrl_o
      .. "O"
      .. slash
  end
  return key_cr
end

api.nvim_set_keymap(
  "i",
  "<Plug>autocloseCR",
  [[v:lua.autoclose.enter()]],
  { noremap = true, expr = true }
)
api.nvim_set_keymap("i", "<Enter>", "<Plug>autocloseCR", {})

_G.autoclose = { enter = enter }
