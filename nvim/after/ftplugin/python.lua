local utils = require("utils")

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

local function pydoc_help(args)
  local output =
    vim.iter(io.popen("python3 -m pydoc " .. args.args):lines()):totable()
  if #output == 0 or output[1]:starts_with("No Python documentation found") then
    vim.notify("E149: Sorry, no help for " .. args.args, vim.log.levels.ERROR)
    return
  end
  utils.help(output)
end

vim.api.nvim_buf_create_user_command(0, "PydocHelp", pydoc_help, { nargs = 1 })
vim.bo.keywordprg = ":PydocHelp"
