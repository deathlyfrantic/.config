vim.opt_local.foldmethod = "marker"
vim.api.nvim_buf_set_keymap(
  0,
  "i",
  "<C-x><C-o>",
  "<C-x><C-v>",
  { noremap = true }
)
