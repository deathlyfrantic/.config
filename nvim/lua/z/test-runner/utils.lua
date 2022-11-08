local api = vim.api

local function get_match_lines(start, num)
  return table.concat(
    api.nvim_buf_get_lines(0, start, start + num, false),
    "\n"
  )
end

local function find_nearest_test(pattern, atom)
  local num_lines = #vim.split(pattern, [[\n]])
  local match = vim.fn.matchlist(
    get_match_lines(api.nvim_win_get_cursor(0)[1] - 1, num_lines),
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

return {
  find_nearest_test = find_nearest_test,
}
