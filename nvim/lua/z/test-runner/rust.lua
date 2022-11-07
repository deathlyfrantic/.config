local api = vim.api
local find_nearest_test = require("z.test-runner.utils").find_nearest_test

local function find_nearest_test_from_treesitter()
  local query = vim.treesitter.parse_query(
    vim.bo.filetype,
    [[((mod_item
      (((identifier) @mod-name (#eq? @mod-name "tests"))
        (declaration_list
          (attribute_item (meta_item (identifier) @attr (#eq? @attr "test")))
            . (function_item (identifier) (block)) @testfn)))
    )]]
  )
  local tree = vim.treesitter.get_parser():parse()
  local cursor_row = api.nvim_win_get_cursor(0)[1]
  local closest = nil
  for id, node, _ in query:iter_captures(tree[1]:root(), 0) do
    local name = query.captures[id]
    if name == "testfn" then
      local row1, _, row2, _ = node:range()
      -- rows are 0-indexed
      row1 = row1 + 1
      row2 = row2 + 1
      -- if the cursor is in the test it's easy
      if row1 <= cursor_row and row2 >= cursor_row then
        return vim.treesitter.query.get_node_text(node:field("name")[1], 0)
      end
      -- cursor not in this test, so check if it's near the cursor.
      -- we're iterating in order so keep setting the closest to the current
      -- node as long as it's before the cursor; if we've passed the cursor and
      -- still haven't found a test, set it to the one closest to the test after
      -- the cursor, then stop.
      if row2 < cursor_row or closest == nil then
        closest = node
      end
    end
  end
  return vim.treesitter.query.get_node_text(closest:field("name")[1], 0)
end

local function test(selection)
  if not vim.fn.executable("cargo") then
    return nil
  end
  -- change to source dir in case file is in a subproject, but strip off the
  -- trailing "src" component e.g. /code/project/src/main.rs -> /code/project
  local cmd = string.format(
    "(cd %s && cargo test)",
    vim.fs.dirname(vim.fs.dirname(api.nvim_buf_get_name(0)))
  )
  if selection == "nearest" then
    local mod_tests_line = vim.fn.search("^mod tests {$", "n")
    if mod_tests_line == 0 then
      return cmd
    end
    local nearest = find_nearest_test_from_treesitter()
    if nearest == nil then
      api.nvim_err_writeln(
        "couldn't find test from treesitter, falling back to regex"
      )
      nearest = find_nearest_test([[#\[test]\n\s*fn\s\+\(\w*\)(]], 2)
    end
    return cmd:sub(1, -2) .. string.format(" %s)", nearest)
  elseif selection == "file" then
    return cmd:sub(1, -2)
      .. string.format(
        " %s::)",
        vim.fn.basename(api.nvim_buf_get_name(0)):match("(.*)%.")
      )
  end
  return cmd
end

return { test = test }
