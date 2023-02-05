local function filename()
  if #vim.api.nvim_buf_get_name(0) > 0 then
    return vim.fs
      .normalize(vim.api.nvim_buf_get_name(0))
      :gsub(vim.fs.normalize("$HOME"), "~")
  end
  return string.format(
    "[cwd: %s]",
    vim.loop.cwd():gsub(vim.fs.normalize("$HOME"), "~")
  )
end

return { filename = filename }
