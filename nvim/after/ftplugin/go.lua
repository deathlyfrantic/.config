local utils = require("utils")

vim.opt_local.expandtab = false
vim.opt_local.shiftwidth = 8
vim.opt_local.textwidth = 80

vim.keymap.set("i", ";;", function()
  return utils.insert_token(":=")
end, { buffer = true, expr = true })
