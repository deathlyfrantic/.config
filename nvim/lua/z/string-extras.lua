function string.trim(self)
  -- for some reason the viml trim() function is _much_ faster than the lua one
  return vim.fn.trim(self)
end

function string.is_empty(self)
  return self:match("^%s*$") ~= nil
end

function string.split(self, sep, opts)
  return vim.split(self, sep, opts)
end

function string.starts_with(self, prefix)
  return vim.startswith(self, prefix)
end

function string.ends_with(self, prefix)
  return vim.endswith(self, prefix)
end

local function string_pad(s, length, padding, direction)
  padding = padding or " "
  if length - vim.fn.strdisplaywidth(s) < 1 then
    return s
  end
  if padding:is_empty() and length < 100 then
    if direction == "right" then
      return ("%-" .. length .. "s"):format(s)
    else
      return ("%" .. length .. "s"):format(s)
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
      pat = pat .. ("[%s%s]"):format(char:upper(), char:lower())
    end
  end
  return self:match(pat)
end
