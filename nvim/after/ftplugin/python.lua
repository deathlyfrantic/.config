-- highlight docstrings as comments
local function docstring_highlight()
  vim.cmd(
    [[syntax region pythonDocstring start=+^\s*[uU]\?[rR]\?\%("""\|'''\)+ ]]
      .. [[end=+\%("""\|'''\)+ keepend excludenl ]]
      .. "contains=pythonEscape,@Spell,pythonDoctest,pythonDocTest2,pythonSpaceError"
  )
  vim.cmd("highlight default link pythonDocstring pythonComment")
end

api.nvim_create_autocmd("Syntax", {
  buffer = 0,
  callback = docstring_highlight,
  group = api.nvim_create_augroup("python-ftplugin", {}),
})
