local M = {}

function M.test()
  local makefile = vim.fn.findfile("Makefile", ";")
  if makefile == "" then
    return nil
  end
  local dir = vim.fs.dirname(makefile)
  for line in io.open(makefile):lines() do
    if line:match("^test:") then
      return ("(cd %s && make test)"):format(dir)
    end
  end
end

return M
