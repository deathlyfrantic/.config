local M = {}

-- Find the starting line of the region. If the cursor is on a blank line, find
-- the closest non-blank line above and below, and choose the one with the
-- largest indent.
---@param lines string[]
---@return integer
local function find_starting_line(lines)
  local starting_line = vim.api.nvim_win_get_cursor(0)[1]
  if lines[starting_line]:is_empty() then
    local top_line, top_indent, bottom_line, bottom_indent
    for i = starting_line, 1, -1 do
      if not lines[i]:is_empty() then
        top_indent = lines[i]:visual_indent()
        top_line = i
        break
      end
    end
    for i = starting_line, #lines do
      if not lines[i]:is_empty() then
        bottom_indent = lines[i]:visual_indent()
        bottom_line = i
        break
      end
    end
    starting_line = top_indent > bottom_indent and top_line or bottom_line
  end
  return starting_line
end

-- Find the terminal position of a region, either top or bottom. If the terminal
-- position is a blank line, returns the last non-blank line instead.
---@param lines string[]
---@param starting_indent integer
---@param start integer
---@param down? boolean
---@return integer
local function find_end_position(lines, starting_indent, start, down)
  local limit = start
  local last_non_blank = start
  for i = start, down and #lines or 1, down and 1 or -1 do
    limit = i
    if not lines[i]:is_empty() then
      if lines[i]:visual_indent() < starting_indent then
        break
      end
      last_non_blank = i
    end
  end
  if down then
    -- last_non_blank is above bottom, meaning that at least the bottom line is
    -- empty, so set bottom to last_non_blank
    if last_non_blank < limit then
      return last_non_blank
    end
    -- bottom line is not empty, so return it
    return limit
  end
  -- last_non_blank is below top, meaning that at least the top line is empty,
  -- so set top to last_non_blank
  if last_non_blank > limit then
    return last_non_blank
  end
  -- top line is not empty, so return it
  return limit
end

---@return integer, integer
local function find_top_and_bottom()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local starting_line = find_starting_line(lines)
  local starting_indent = lines[starting_line]:visual_indent()
  local top = find_end_position(lines, starting_indent, starting_line)
  local bottom = find_end_position(lines, starting_indent, starting_line, true)
  return top, bottom
end

function M.textobject()
  local top, bottom = find_top_and_bottom()
  vim.api.nvim_win_set_cursor(0, { top, 0 })
  vim.cmd.normal({ args = { "V" }, bang = true })
  vim.api.nvim_win_set_cursor(0, { bottom, 0 })
end

function M.init()
  vim.keymap.set(
    { "o", "v" },
    "ii",
    [[:<C-u>lua require("text-objects.indent").textobject()<CR>]],
    { silent = true }
  )
end

return M
