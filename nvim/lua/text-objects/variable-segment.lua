local M = {}

---@alias StartType "lowercase" | "uppercase" | "digit" | "word" | "other"

local patterns = {
  lowercase = "%l",
  uppercase = "%u",
  digit = "%d",
  word = "%w",
}

---@param char string
---@return StartType
local function char_type(char)
  -- key/value tables don't have a guaranteed order so we have to be explicit
  -- about it because the 'word' pattern will match the lowercase, uppercase and
  -- digit patterns.
  local ordered = { "lowercase", "uppercase", "digit", "word" }
  for _, pattern_type in ipairs(ordered) do
    if char:match(patterns[pattern_type]) then
      return pattern_type
    end
  end
  return "other"
end

---@param col integer
---@return string
local function char_at(col)
  return vim.api.nvim_get_current_line():sub(col, col)
end

-- Find the starting column of the match. If the cursor is on a word character
-- then it is the cursor position (most of the time). If the cursor is not on a
-- word character, then find the closest word character and return that
-- position.
---@param col integer
---@return integer
local function find_start(col)
  -- in the case of FooBARBaz, if cursor is on the 'B' of Baz, the variable
  -- segment we want is Baz. set the start to the 'a' in Baz so the boundary
  -- finding logic has an easier job.
  if char_at(col):match(patterns.uppercase) then
    if char_at(col + 1):match(patterns.lowercase) then
      return col + 1
    end
  end
  -- normal case, cursor on a word character
  if char_at(col):match(patterns.word) then
    return col
  end
  -- cursor not on a word character
  local left = 1
  local right = #vim.api.nvim_get_current_line()
  for i = col, 1, -1 do
    if char_at(i):match(patterns.word) then
      left = i
      break
    end
  end
  for i = col, right do
    if char_at(i):match(patterns.word) then
      right = i
      break
    end
  end
  -- return the position closer to the cursor
  return col - left <= right - col and left or right
end

---@param start integer
---@param start_type StartType
---@return integer
local function find_left(start, start_type)
  for i = start, 1, -1 do
    local c_type = char_type(char_at(i))
    if c_type ~= start_type then
      -- given FooBar, starting on the 'a' in Bar, we want to include the 'B' as
      -- part of the segment, so we return it as the left; otherwise, add 1 to
      -- return the last character matching the start type.
      return start_type == "lowercase" and c_type == "uppercase" and i or i + 1
    end
  end
  return 1
end

---@param start integer
---@param start_type StartType
---@param left integer
---@return integer
local function find_right(start, start_type, left)
  local line_length = #vim.api.nvim_get_current_line()
  for i = start, line_length do
    local c_type = char_type(char_at(i))
    if c_type ~= start_type then
      if start_type == "uppercase" and c_type == "lowercase" then
        -- in the case of FooBARBaz, we want to select just BAR. so on the 'a'
        -- in Baz, remove the 'B' from Baz so we just get BAR. but if there is
        -- only a single uppercase letter, e.g. FooBaz, don't do this. we
        -- don't have to worry about whether the start is on the 'B' of Baz
        -- because find_start will set the start to the 'a' in Baz in this
        -- case.
        return i - left >= 2 and i - 2 or i - 1
      end
      return i - 1
    end
  end
  return line_length
end

---@param mode "i" | "a"
---@param count? integer
function M.textobject(mode, count)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  -- add 1 to cursor pos to shift from 0-indexed (columns) to 1-indexed (lua)
  local col = cursor_pos[2] + 1
  local start = find_start(col)
  local start_type = char_type(char_at(start))
  local left = find_left(start, start_type)
  local right = find_right(start, start_type, left)
  -- keep searching if a count was provided
  for _ = 1, (count or 1) - 1 do
    local new_start = right + 1
    -- don't start on an underscore
    while char_at(new_start) == "_" do
      new_start = new_start + 1
    end
    -- stop if we get to a space
    if char_at(new_start):match("%s") then
      right = new_start - 1
      break
    end
    new_start = find_start(new_start)
    local new_start_type = char_type(char_at(new_start))
    local new_left = find_left(new_start, new_start_type)
    right = find_right(new_start, new_start_type, new_left)
  end
  if mode == "a" then
    while char_at(right + 1) == "_" do
      right = right + 1
    end
  end
  -- subtract 1 from right and left positions to shift from 1-indexed (lua) to
  -- 0-indexed (columns)
  vim.api.nvim_win_set_cursor(0, { cursor_pos[1], left - 1 })
  vim.cmd.normal({ args = { "v" }, bang = true })
  vim.api.nvim_win_set_cursor(0, { cursor_pos[1], right - 1 })
end

function M.init()
  vim.keymap.set(
    { "o", "v" },
    "iv",
    [[:<C-u>lua require("text-objects.variable-segment").textobject("i", vim.v.count)<CR>]],
    { silent = true }
  )
  vim.keymap.set(
    { "o", "v" },
    "av",
    [[:<C-u>lua require("text-objects.variable-segment").textobject("a", vim.v.count)<CR>]],
    { silent = true }
  )
end

return M
