local function test()
  local makefile = vim.fn.findfile("Makefile", ";")
  if makefile == "" then
    return nil
  end
  local dir = vim.fs.dirname(makefile)
  for line in io.open(makefile):lines() do
    if line:match("^test:") then
      return string.format("(cd %s && make test)", dir)
    end
  end
end

return { test = test }
