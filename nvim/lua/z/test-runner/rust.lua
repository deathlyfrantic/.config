local utils = require("z.test-runner.utils")

local M = {}

function M.find_nearest_treesitter()
  return utils.find_nearest_test_via_treesitter(
    [[((mod_item
      (((identifier) @mod-name (#eq? @mod-name "tests"))
        (declaration_list
          (attribute_item (attribute (identifier) @attr (#eq? @attr "test")))
            . (function_item (identifier) (block)) @testfn))))
    ]],
    "testfn",
    function(node)
      return node:field("name")[1]
    end
  )
end

function M.find_nearest_regex()
  vim.notify(
    "couldn't find test from treesitter, falling back to regex",
    vim.log.levels.ERROR
  )
  return utils.find_nearest_test([[#\[test]\n\s*fn\s\+\(\w*\)(]], 2)
end

function M.test(selection)
  if vim.fn.executable("cargo") == 0 then
    return nil
  end
  -- change to source dir in case file is in a subproject, but strip off the
  -- trailing "src" component e.g. /code/project/src/main.rs -> /code/project
  local cmd = ("(cd %s && cargo test)"):format(
    vim.fs.dirname(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
  )
  if selection == "nearest" then
    -- don't look for a test if we can't find the `mod tests {}` declaration
    if vim.fn.search("^\\s*mod tests {$", "n") > 0 then
      local nearest = M.find_nearest_treesitter() or M.find_nearest_regex()
      if nearest ~= nil then
        return ("%s %s)"):format(cmd:sub(1, -2), nearest)
      end
    end
  elseif selection == "file" then
    return ("%s %s::)"):format(
      cmd:sub(1, -2),
      vim.fs.basename(vim.api.nvim_buf_get_name(0)):match("(.*)%.")
    )
  end
  return cmd
end

return M
