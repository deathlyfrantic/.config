local utils = require("utils")

local M = {}

function M.set_cursor(row, col, win)
  vim.api.nvim_win_set_cursor(win or 0, { row or 1, col or 0 })
end

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

function M.clear_buf(buf)
  M.set_buf({}, buf)
end

function M.clear_filetype()
  vim.cmd.setlocal("filetype=")
end

function M.get_buf(buf)
  return vim.api.nvim_buf_get_lines(buf or 0, 0, -1, false)
end

-- this is a hacky way to access the otherwise-hidden callback for a keymap
-- but it works, and it's easier than trying to use insert mode in a test
function M.get_keymap_callback(mode, key)
  return utils.tbl_find(function(mapping)
    return mapping.lhs == key
  end, vim.api.nvim_get_keymap(mode)).callback
end

return M
