if vim.startswith(vim.fn.expand("%:p", true), vim.env.VIMHOME) then
  vim.opt_local.keywordprg = ":help"
end
