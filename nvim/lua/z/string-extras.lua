function string.trim(self)
  -- for some reason the viml trim() function is _much_ faster than the lua one
  return vim.fn.trim(self)
end

function string.split(self, sep)
  return vim.split(self, sep, true)
end

function string.is_empty(self)
  local start, _ = self:match("^%s*$")
  return start ~= nil
end

local function string_pad(s, length, padding, direction)
  padding = padding or " "
  if length - vim.fn.strdisplaywidth(s) < 1 then
    return s
  end
  if padding:match("^%s*$") and length < 100 then
    if direction == "right" then
      return string.format("%-" .. length .. "s", s)
    else
      return string.format("%" .. length .. "s", s)
    end
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

function string.lpad(self, length, padding)
  return string_pad(self, length, padding, "left")
end

function string.rpad(self, length, padding)
  return string_pad(self, length, padding, "right")
end

local function string_chars(s, i)
  if #s > i then
    i = i + 1
    return i, s:sub(i, i)
  end
end

function string.chars(self)
  return string_chars, self, 0
end

function string.imatch(self, pattern)
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
      pat = pat .. string.format("[%s%s]", char:upper(), char:lower())
    end
  end
  return self:match(pat)
end