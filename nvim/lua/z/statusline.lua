local M = {}

function M.filename()
  local bufname = vim.api.nvim_buf_get_name(0)
  if #bufname > 0 then
    return vim.fs.normalize(bufname):gsub(vim.fs.normalize("$HOME"), "~")
  end
  return ("[cwd: %s]"):format(
    vim.loop.cwd():gsub(vim.fs.normalize("$HOME"), "~")
  )
end

function M.treesitter()
  local ok, result = pcall(vim.treesitter.get_node)
  return ok and result and result:type() or ""
end

return M
