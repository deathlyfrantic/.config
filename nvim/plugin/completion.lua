local completion = require("z.completion")

vim.api.nvim_create_autocmd("CompleteDone", {
  pattern = "*",
  callback = completion.undouble,
  group = vim.api.nvim_create_augroup("completion-undouble", {}),
})

vim.keymap.set("i", "<Tab>", function()
  return completion.tab(true)
end, { silent = true, expr = true })
vim.keymap.set("i", "<S-Tab>", function()
  return completion.tab(false)
end, { silent = true, expr = true })
vim.keymap.set("i", "<C-x><C-g>", completion.gitcommit, { silent = true })
