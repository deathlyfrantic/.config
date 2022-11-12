local dedent = require("plenary.strings").dedent

local function set_cursor(row, col, win)
  vim.api.nvim_win_set_cursor(win or 0, { row or 1, col or 0 })
end

local function set_buf(lines, buf)
  if type(lines) == "string" then
    if lines:match("\n") then
      lines = dedent(lines):split("\n")
    else
      lines = { lines }
    end
  end
  vim.api.nvim_buf_set_lines(buf or 0, 0, -1, false, lines or {})
end

local function clear_buf(buf)
  set_buf({}, buf)
end

local function clear_filetype()
  -- doing it this way prevents the "unknown filetype" error from printing
  vim.cmd("silent! setlocal filetype ''")
end

return {
  set_cursor = set_cursor,
  set_buf = set_buf,
  clear_buf = clear_buf,
  clear_filetype = clear_filetype,
}
