-- highlight docstrings as comments
local function docstring_highlight()
  if vim.bo.syntax == "" then
    return
  end
  vim.cmd.syntax(
    [[region pythonDocstring start=+^\s*[uU]\?[rR]\?\%("""\|'''\)+ ]]
      .. [[end=+\%("""\|'''\)+ keepend excludenl ]]
      .. "contains=pythonEscape,@Spell,pythonDoctest,pythonDocTest2,pythonSpaceError"
  )
  vim.cmd.highlight("default link pythonDocstring pythonComment")
end

vim.api.nvim_create_autocmd("Syntax", {
  buffer = 0,
  callback = docstring_highlight,
  group = vim.api.nvim_create_augroup("python-ftplugin", {}),
})
