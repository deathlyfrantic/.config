local utils = require("test-runner.utils")

local M = {}

function M.find_nearest_treesitter()
  -- finds tests according to pytest's discovery rules
  -- https://docs.pytest.org/explanation/goodpractices.html#test-discovery
  -- i.e. functions that start with `test` that are top-level, or in classes
  -- that start with `Test`. (technically it should only find tests in `Test*`
  -- classes without an `__init__` method but that's not worth the effort of
  -- putting in here.)
  return utils.find_nearest_test_via_treesitter(
    [[(class_definition
      name: ((identifier) @classname (#match? @classname "^Test"))
      (block
        (function_definition
          name: ((identifier) @testname (#match? @testname "^test")))))

      (module ((function_definition
        name: ((identifier) @testname (#match? @testname "^test")))))
    ]],
    "testname"
  )
end

function M.find_nearest_regex()
  vim.notify(
    "couldn't find test from treesitter, falling back to regex",
    vim.log.levels.ERROR
  )
  return utils.find_nearest_test([[^\s*def \(test\w*\)]], 2)
end

function M.pytest(selection)
  local filename = vim.api.nvim_buf_get_name(0)
  if selection == "nearest" then
    local nearest = M.find_nearest_treesitter() or M.find_nearest_regex()
    if nearest then
      return "pytest " .. filename .. "::" .. nearest
    end
  elseif selection == "file" then
    return "pytest " .. filename
  end
  return "pytest"
end

function M.test(selection)
  return vim.fn.executable("pytest") == 1 and M.pytest(selection)
    or "python3 -m unittest"
end

return M
