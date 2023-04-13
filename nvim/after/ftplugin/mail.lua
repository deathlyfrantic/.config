local api = vim.api

vim.opt_local.formatoptions:remove({ "o", "r" })
vim.opt_local.formatoptions:append({ "w" })
vim.opt_local.textwidth = 72
vim.opt_local.spell = true

local header_end = -1

-- find the blank line(s) between the headers and the body
local function update_header_end()
  local i = 0
  while i <= api.nvim_buf_line_count(0) do
    if api.nvim_buf_get_lines(0, i, i + 1, true)[1]:is_empty() then
      header_end = i
      return
    end
    i = i + 1
  end
  header_end = -1
end

-- adjust 'a' formatoption based on cursor position
local function adjust_foa_for_headers()
  if api.nvim_win_get_cursor(0)[1] <= header_end then
    vim.opt_local.formatoptions:remove("a")
  else
    vim.opt_local.formatoptions:append("a")
  end
end

local group = api.nvim_create_augroup("mail-ftplugin", {})
api.nvim_create_autocmd(
  "InsertLeave",
  { buffer = 0, callback = update_header_end, group = group }
)
api.nvim_create_autocmd(
  "CursorMoved",
  { buffer = 0, callback = adjust_foa_for_headers, group = group }
)

update_header_end()
