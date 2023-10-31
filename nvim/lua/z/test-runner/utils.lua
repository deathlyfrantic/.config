local M = {}

local function get_match_lines(start, num)
  return table.concat(
    vim.api.nvim_buf_get_lines(0, start, start + num, false),
    "\n"
  )
end

function M.find_nearest_test(pattern, atom)
  local num_lines = #pattern:split([[\n]])
  local match = vim.fn.matchlist(
    get_match_lines(vim.api.nvim_win_get_cursor(0)[1] - 1, num_lines),
    pattern
  )
  if #match > 0 then
    return match[atom]
  end
  local before = vim.fn.search(pattern, "bnW")
  if before ~= 0 then
    return vim.fn.matchlist(get_match_lines(before - 1, num_lines), pattern)[atom]
  end
  local after = vim.fn.search(pattern, "nW")
  if after ~= 0 then
    return vim.fn.matchlist(get_match_lines(after - 1, num_lines), pattern)[atom]
  end
end

function M.find_nearest_test_via_treesitter(sexpr, capture_name, node_text_fn)
  node_text_fn = node_text_fn or function(node)
    return node
  end
  local query = vim.treesitter.query.parse(vim.bo.filetype, sexpr)
  local tree = vim.treesitter.get_parser():parse()
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
  local nearest = nil
  for id, node, _ in query:iter_captures(tree[1]:root(), 0) do
    if query.captures[id] == capture_name then
      local row1, _, row2, _ = node:range()
      -- rows are 0-indexed
      row1 = row1 + 1
      row2 = row2 + 1
      -- if the cursor is in the test it's easy
      if row1 <= cursor_row and row2 >= cursor_row then
        return vim.treesitter.get_node_text(node_text_fn(node), 0)
      end
      -- cursor not in this test, so check if it's near the cursor.
      -- we're iterating in order so keep setting the closest to the current
      -- node as long as it's before the cursor; if we've passed the cursor and
      -- still haven't found a test, set it to the one closest to the test after
      -- the cursor, then stop.
      if row2 < cursor_row or nearest == nil then
        nearest = node
      end
    end
  end
  if nearest ~= nil then
    return vim.treesitter.get_node_text(node_text_fn(nearest), 0)
  end
  return nil
end

return M
