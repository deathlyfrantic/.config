if
  vim.startswith(vim.fn.expand("%:p", true), vim.env.VIMHOME)
  or vim.fn.expand("%"):match(".vimrc.lua$")
then
  vim.opt_local.keywordprg = ":help"
  vim.b.ale_lua_selene_options = "--config "
    .. vim.fn.expand("$VIMHOME/selene.toml")
end
