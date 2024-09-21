vim.opt_local.commentstring = "// %s"
vim.opt_local.shiftwidth = 2
vim.opt_local.textwidth = 80

vim.keymap.set("ia", "!=", "!==", { buffer = true })
vim.keymap.set("ia", "==", "===", { buffer = true })
vim.keymap.set("ia", "fn!", "function", { buffer = true })
