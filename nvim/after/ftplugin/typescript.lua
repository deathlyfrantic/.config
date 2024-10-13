-- use javascript config as a base
vim.cmd.luafile(
  vim.fs.joinpath(
    vim.fn.stdpath("config"),
    "after",
    "ftplugin",
    "javascript.lua"
  )
)
