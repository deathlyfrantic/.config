local utils = require("utils")

local M = {}

-- this is a recreation of the coercion logic in vim-abolish by Tim Pope
-- https://github.com/tpope/vim-abolish/

---@param s string
---@return string
function M.camel_case(s)
  local ret, _ = s:gsub("-", "_")
  if not ret:match("_") and ret:match("%l") then
    -- special case so we don't change an already camel-cased word e.g. FooBar
    return ret:sub(1, 1):lower() .. ret:sub(2)
  end
  ret, _ = ret:gsub("(_*)(.)", function(a, b)
    return a:is_empty() and b:lower() or a == "_" and b:upper() or "_" .. b
  end)
  return ret
end

---@param s string
---@return string
function M.mixed_case(s)
  local camel = M.camel_case(s)
  return camel:sub(1, 1):upper() .. camel:sub(2)
end

---@param s string
---@return string
function M.snake_case(s)
  return s:gsub("::", "/")
    :gsub("(%u+)(%u%l)", "%1_%2")
    :gsub("([%l%d])(%u)", "%1_%2")
    :gsub("[.-]", "_")
    :lower()
end

---@param replacement string
---@return fun(string): string
local function replace_snake(replacement)
  ---@param s string
  ---@return string
  return function(s)
    local ret, _ = M.snake_case(s):gsub("_", replacement)
    return ret
  end
end

M.dash_case = replace_snake("-")
M.dot_case = replace_snake(".")
M.space_case = replace_snake(" ")

---@param s string
---@return string
function M.upper_case(s)
  return M.snake_case(s):upper()
end

M.operator = utils.make_operator_fn(function(text)
  local start = vim.api.nvim_buf_get_mark(0, "[")
  local stop = vim.api.nvim_buf_get_mark(0, "]")
  local row, start_col, stop_col = start[1] - 1, start[2], stop[2] + 1
  local replacement = M.current_transform(text)
  if replacement ~= text then
    vim.api.nvim_buf_set_text(0, row, start_col, row, stop_col, { replacement })
  end
end)

function M.init()
  local keymaps = {
    c = M.camel_case,
    m = M.mixed_case,
    p = M.mixed_case,
    s = M.snake_case,
    _ = M.snake_case,
    u = M.upper_case,
    U = M.upper_case,
    ["-"] = M.dash_case,
    k = M.dash_case,
    ["."] = M.dot_case,
    [" "] = M.space_case,
  }
  for key, transform in pairs(keymaps) do
    vim.keymap.set("n", "cr" .. key, function()
      M.current_transform = transform
      vim.o.opfunc = "v:lua.require'coerce'.operator"
      return "g@iw"
    end, { expr = true, silent = true })
  end
  -- set default empty transform just in case
  M.current_transform = function(s)
    return s
  end
end

return M
