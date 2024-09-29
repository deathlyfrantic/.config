local utils = require("utils")
local test_utils = require("test-runner.utils")

local M = {}

---@return string?
function M.find_nearest_treesitter()
  return test_utils.find_nearest_test_via_treesitter(
    [[(function_declaration
      name: ((identifier) @testname (#match? @testname "^Test")))]],
    "testname"
  )
end

---@return string?
function M.find_nearest_regex()
  vim.notify(
    "couldn't find test from treesitter, falling back to regex",
    vim.log.levels.ERROR
  )
  return test_utils.find_nearest_test([[^\s*func \(Test\w*\)]], 2)
end

---@param selection TestRunnerSelection
---@return string?
function M.test(selection)
  local base_cmd = ('go test -v "%s"'):format(
    vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  )
  if selection == "nearest" then
    local nearest = M.find_nearest_treesitter() or M.find_nearest_regex()
    if nearest then
      return ("%s -run %s"):format(base_cmd, nearest)
    end
  elseif selection == "file" then
    return base_cmd
  end
  -- `find_project_dir()` includes the trailing slash so we don't need it here
  -- in the command, i.e. we're doing `go test $dir/...`
  return ('go test -v "%s..."'):format(utils.find_project_dir())
end

return M
