-- super specific functionality to squeeze empty space out of vim-dadbod output
-- may only apply to sql server ¯\_(ツ)_/¯
local nvim = require("nvim")
local z = require("z")

local function find_columns(line)
  local cols, start = {}, 1
  for i = start, #line do
    if line:sub(i, i) ~= "-" then
      table.insert(cols, {start = start, stop = i})
      start = i
    end
  end
  table.insert(cols, {start = start, stop = #line})
  return cols
end

local function find_max_content_length(lines)
  local cols = find_columns(lines[2])
  for _, c in ipairs(cols) do
    local max = #lines[1]:sub(c.start, c.stop):trim()
    for i = 3, #lines do
      max = math.max(#lines[i]:sub(c.start, c.stop):trim(), max)
    end
    c.max = max
  end
  return cols
end

local function squeeze_contents(lines)
  local cols = find_max_content_length(lines)
  local headers = ""
  for i = #cols, 1, -1 do
    local c = cols[i]
    headers = lines[1]:sub(c.start, c.stop):trim():rpad(c.max + 1) .. headers
  end
  local separators = ""
  for i = #cols, 1, -1 do
    separators = string.rep("-", cols[i].max) .. " " .. separators
  end
  lines[1] = headers
  lines[2] = separators
  for i = 3, #lines do
    local row = ""
    for j = #cols, 1, -1 do
      local c = cols[j]
      row = lines[i]:sub(c.start, c.stop):trim():lpad(c.max) .. " " .. row
    end
    lines[i] = row
  end
  return lines
end

local function squeeze()
  local lines = nvim.buf_get_lines(0, 0, -3, false)
  nvim.bo.modifiable = true
  nvim.bo.readonly = false
  nvim.buf_set_lines(0, 0, #lines, false, squeeze_contents(lines))
  nvim.bo.modifiable = false
  nvim.bo.readonly = true
  nvim.bo.modified = false
end

local function on_load(max)
  -- ensure second line is a separator row (implying first is header)
  local second_line = nvim.buf_get_lines(0, 1, 2, false)[1]
  if second_line == nil or second_line:sub(1, 1) ~= "-" then
    return
  end
  -- ensure second-to-last line is blank (implying last is "x rows affected")
  local second_to_last_line = nvim.buf_get_lines(0, -3, -2, false)[1]
  if second_to_last_line == nil or second_to_last_line ~= "" then
    return
  end
  if nvim.fn.line("$") <= max then
    squeeze()
  end
end

return {
  squeeze = squeeze,
  on_load = on_load
}
