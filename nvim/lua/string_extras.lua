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
  local addl = length - vim.fn.strdisplaywidth(s)
  if addl < 1 then
    return s
  end
  if padding == " " and addl < 100 then
    if direction == "right" then
      return s .. string.format("%-" .. addl .. "s", " ")
    else
      return string.format("%-" .. addl .. "s", " ") .. s
    end
  end
  for _ = 1, addl do
    if direction == "right" then
      s = s .. padding
    else
      s = padding .. s
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
