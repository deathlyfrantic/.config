local bufname = vim.api.nvim_buf_get_name(0)
if
  bufname:starts_with(vim.fn.stdpath("config"))
  or bufname:ends_with(".vimrc.lua")
then
  vim.opt_local.keywordprg = ":help"
  vim.opt_local.omnifunc = "v:lua.vim.lua_omnifunc"
  vim.b.ale_lua_selene_options =
    string.format("--config %s/selene.toml", vim.fn.stdpath("config"))
end
