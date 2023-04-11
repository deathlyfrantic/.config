local bufname = vim.api.nvim_buf_get_name(0)
if
  vim.startswith(bufname, vim.env.VIMHOME)
  or vim.endswith(bufname, ".vimrc.lua")
then
  vim.opt_local.keywordprg = ":help"
  vim.opt_local.omnifunc = "v:lua.vim.lua_omnifunc"
  vim.b.ale_lua_selene_options = "--config "
    .. vim.fs.normalize("$VIMHOME/selene.toml")
end
