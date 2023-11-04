vim.b.test_command = string.format(
  "command nvim --headless -c 'packadd plenary.nvim' -c 'PlenaryBustedFile %s'",
  vim.fs.normalize(vim.api.nvim_buf_get_name(0))
)
