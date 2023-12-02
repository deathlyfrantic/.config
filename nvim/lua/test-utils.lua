local utils = require("utils")

local M = {}

---@param row? integer
---@param col? integer
---@param win? integer
function M.set_cursor(row, col, win)
  vim.api.nvim_win_set_cursor(win or 0, { row or 1, col or 0 })
end

---@param lines string | string[]
---@param buf? integer
function M.set_buf(lines, buf)
  if type(lines) == "string" then
    if lines:match("\n") then
      lines = lines:dedent():split("\n", { plain = true })
    else
      lines = { lines }
    end
  end
  vim.api.nvim_buf_set_lines(buf or 0, 0, -1, false, lines or {})
end

---@param buf? integer
function M.clear_buf(buf)
  M.set_buf({}, buf)
end

function M.clear_filetype()
  vim.cmd.setlocal("filetype=")
end

---@param buf? integer
---@return string[]
function M.get_buf(buf)
  return vim.api.nvim_buf_get_lines(buf or 0, 0, -1, false)
end

-- this is a hacky way to access the otherwise-hidden callback for a keymap
-- but it works, and it's easier than trying to use insert mode in a test
---@param mode string
---@param key string
---@return function
function M.get_keymap_callback(mode, key)
  return utils.tbl_find(function(mapping)
    return mapping.lhs == key
  end, vim.api.nvim_get_keymap(mode)).callback
end

---@param start integer[]
---@param stop integer[]
function M.set_visual_marks(start, stop)
  vim.api.nvim_buf_set_mark(0, "<", start[1] or 1, start[2] or 0, {})
  vim.api.nvim_buf_set_mark(
    0,
    ">",
    stop[1] or vim.api.nvim_buf_line_count(0),
    stop[2] or 2147483647,
    {}
  )
end

return M
