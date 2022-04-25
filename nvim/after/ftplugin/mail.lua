vim.opt_local.formatoptions:remove({ "o", "r" })
vim.opt_local.formatoptions:append({ "w" })
vim.opt_local.textwidth = 72
vim.cmd("setlocal spell")

local header_end = -1

-- find the blank line(s) between the headers and the body
local function update_header_end()
  local i = 0
  while i <= vim.fn.line("$") do
    if vim.api.nvim_buf_get_lines(0, i, i + 1, true)[1]:is_empty() then
      header_end = i
      return
    end
    i = i + 1
  end
  header_end = -1
end

-- adjust 'a' formatoption based on cursor position
local function adjust_foa_for_headers()
  if vim.fn.line(".") <= header_end then
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
