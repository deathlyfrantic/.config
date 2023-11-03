local dedent = require("plenary.strings").dedent

local M = {}

function M.set_cursor(row, col, win)
  vim.api.nvim_win_set_cursor(win or 0, { row or 1, col or 0 })
end

function M.set_buf(lines, buf)
  if type(lines) == "string" then
    if lines:match("\n") then
      lines = dedent(lines):split("\n", { plain = true })
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

return M
