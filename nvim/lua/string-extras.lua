-- Trim whitespace from both sides of string
---@param self string
---@return string
function string.trim(self)
  -- for some reason the viml trim() function is _much_ faster than the lua one
  return vim.fn.trim(self)
end

-- True if string is only whitespace
---@param self string
---@return boolean
function string.is_empty(self)
  return self:match("^%s*$") ~= nil
end

-- Split string into a list of strings based on a separator. Default options are
-- reverse of `vim.split`.
---@param self string
---@param sep string
---@param opts { plain?: boolean, trimempty?: boolean }?
---@return string[]
function string.split(self, sep, opts)
  local defaults = { plain = true, trimempty = true }
  return vim.split(self, sep, vim.tbl_extend("force", defaults, opts or {}))
end

-- True if string starts with prefix
---@param self string
---@param prefix string
---@return boolean
function string.starts_with(self, prefix)
  return vim.startswith(self, prefix)
end

-- True if string ends with suffix
---@param self string
---@param suffix string
---@return boolean
function string.ends_with(self, suffix)
  return vim.endswith(self, suffix)
end

-- Pad string to specified length with provided padding (or space by default)
---@param s string
---@param length integer
---@param padding string?
---@param direction "left" | "right"
---@return string
local function string_pad(s, length, padding, direction)
  padding = padding or " "
  if length - vim.fn.strdisplaywidth(s) < 1 then
    return s
  end
  if padding:is_empty() and length < 100 then
    return direction == "right" and ("%-" .. length .. "s"):format(s)
      or ("%" .. length .. "s"):format(s)
  end
  while #s < length do
    local addl = length - #s
    if direction == "right" then
      s = s .. padding:sub(1, addl)
    else
      s = padding:sub(1, addl) .. s
    end
  end
  return s
end

-- Pad string to length with padding added to the left
---@param self string
---@param length integer
---@param padding string?
---@return string
function string.lpad(self, length, padding)
  return string_pad(self, length, padding, "left")
end

-- Pad string to length with padding added to the right
---@param self string
---@param length integer
---@param padding string?
---@return string
function string.rpad(self, length, padding)
  return string_pad(self, length, padding, "right")
end

-- String char iterator function
---@param s string
---@param i integer
local function string_chars(s, i)
  if #s > i then
    i = i + 1
    return i, s:sub(i, i)
  end
end

-- Iterator of characters in the string
---@param self string
---@return function, string, integer
function string.chars(self)
  return string_chars, self, 0
end

local imatch_cache = {}

-- Case-insensitive version of `string.match`
---@param self string
---@param pattern string
---@return string?
function string.imatch(self, pattern)
  if not imatch_cache[pattern] then
    local pat = ""
    local in_percent = false
    local in_bracket = false
    for _, char in pattern:chars() do
      if in_percent then
        pat = pat .. char
        in_percent = false
      elseif char == "%" then
        pat = pat .. char
        in_percent = true
      elseif in_bracket then
        pat = pat .. char
        if char == "]" then
          in_bracket = false
        end
      elseif char == "[" then
        pat = pat .. char
        in_bracket = true
      elseif char:match("%A") then
        pat = pat .. char
      else
        pat = pat .. ("[%s%s]"):format(char:upper(), char:lower())
      end
    end
    imatch_cache[pattern] = pat
  end
  return self:match(imatch_cache[pattern])
end

-- Dedent string by removing smallest common whitespace from front of each line.
---@param self string
---@return string
function string.dedent(self)
  local lines = self:splitlines(false)
  -- determine the number of leading tabs and spaces per line
  local stats = vim.tbl_map(function(line)
    local indent = line:match("^%s*")
    local _, tabs = indent:gsub("\t", "")
    local _, spaces = indent:gsub(" ", "")
    return { tabs = tabs, spaces = spaces }
  end, lines)
  -- find the smallest common number of leading tabs and spaces
  local min_values = vim.iter(stats):enumerate():fold(
    { tabs = math.huge, spaces = math.huge },
    function(acc, i, stat)
      -- ignore stats for blank lines
      return #lines[i] == 0 and acc
        or {
          tabs = math.min(acc.tabs, stat.tabs),
          spaces = math.min(acc.spaces, stat.spaces),
        }
    end
  )
  -- rebuild the lines
  return vim
    .iter(stats)
    :enumerate()
    :map(function(i, stat)
      -- empty lines should be returned as empty lines
      return #lines[i] == 0 and ""
        -- start with tabs
        or ("\t"):rep(stat.tabs - min_values.tabs)
          -- then add spaces
          .. (" "):rep(stat.spaces - min_values.spaces)
          -- then the non-leading-whitespace contents of the line
          .. lines[i]:gsub("^%s*", "")
    end)
    :join("\n")
end

-- Returns the visual width of the string's indent, assuming the string starts
-- at screen column 0.
---@param self string
---@return integer
function string.visual_indent(self)
  return vim.fn.strdisplaywidth(self:match("^%s*"))
end

-- Split a string on line separators. List of separators comes from Python's
-- `str.splitlines` method.
-- Reference: https://docs.python.org/3/library/stdtypes.html#str.splitlines
---@param self string
---@param trimempty boolean?
---@return string[]
function string.splitlines(self, trimempty)
  -- selene: allow(bad_string_escape)
  local separators = {
    "\r\n", -- must be first so we don't break a sequence by replacing \r
    "\r",
    "\v",
    "\f",
    "\x1c",
    "\x1d",
    "\x1e",
    "\x85",
    "\u{2028}",
    "\u{2029}",
  }
  local s = self
  for _, sep in ipairs(separators) do
    s, _ = s:gsub(sep, "\n")
  end
  return s:split("\n", { plain = true, trimempty = trimempty })
end
