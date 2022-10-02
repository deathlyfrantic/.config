local api = vim.api

vim.opt_local.cinoptions:append({ "l1" })
vim.opt_local.commentstring = "//%s"

local headers = {
  "assert",
  "ctype",
  "inttypes",
  "limits",
  "signal",
  "stdbool",
  "stdint",
  "stdio",
  "stdlib",
  "string",
  "time",
  "unistd",
}

local nested_headers = { systypes = "sys/types" }

for _, h in ipairs(headers) do
  vim.cmd(string.format("iabbrev <buffer> %sh #include <%s.h>", h, h))
end

for h, f in pairs(nested_headers) do
  vim.cmd(string.format("iabbrev <buffer> %sh #include <%s.h>", h, f))
end

if
  vim.fn.expand("%:e") == "h"
  and api.nvim_buf_line_count(0) > 0
  and api.nvim_buf_get_lines(0, 0, 1, true)[1] == ""
then
  local guard = string.format(
    "%s_%s",
    string.upper(vim.fn.fnamemodify(vim.loop.cwd(), ":t")),
    string.upper(vim.fn.expand("%:t")):gsub("[^A-Z0-9]", "_")
  )
  local new_lines = {
    "#ifndef " .. guard,
    "#define " .. guard,
    "",
    "",
    "",
    "#endif /* end of include guard: " .. guard .. "*/",
  }
  api.nvim_buf_set_lines(0, 0, 1, true, new_lines)
  api.nvim_win_set_cursor(0, { 4, 1 })
end
