local autocmd = require("autocmd")

vim.opt_local.formatoptions:remove({ "o", "r" })
vim.opt_local.formatoptions:append({ "w" })
vim.opt_local.textwidth = 72
vim.opt_local.spell = true

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

autocmd.augroup("mail-ftplugin", function(add)
  add("InsertLeave", "<buffer>", update_header_end, { unique = true })
  add("CursorMoved", "<buffer>", adjust_foa_for_headers, { unique = true })
end)

update_header_end()
