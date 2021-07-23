-- highlight docstrings as comments
local function docstring_highlight()
  vim.cmd(
    [[syntax region pythonDocstring start=+^\s*[uU]\?[rR]\?\%("""\|'''\)+ ]]
      .. [[end=+\%("""\|'''\)+ keepend excludenl ]]
      .. "contains=pythonEscape,@Spell,pythonDoctest,pythonDocTest2,pythonSpaceError"
  )
  vim.cmd("highlight default link pythonDocstring pythonComment")
end

require("autocmd").add(
  "Syntax",
  "<buffer>",
  docstring_highlight,
  { augroup = "python-ftplugin", unique = true }
)
