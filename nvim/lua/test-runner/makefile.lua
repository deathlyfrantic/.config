local M = {}

---@return string?
function M.test()
  local paths = vim.fs.find("Makefile", {
    upward = true,
    stop = vim.loop.os_homedir(),
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    type = "file",
  })
  if #paths == 0 then
    return
  end
  local dir = vim.fs.dirname(paths[1])
  for line in io.open(paths[1]):lines() do
    if line:match("^test:") then
      return ("(cd %s && make test)"):format(dir)
    end
  end
end

return M
