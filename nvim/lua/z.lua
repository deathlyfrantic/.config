local v = vim.api

local function filter(t, f)
  local ret = {}
  for i, v in ipairs(t) do
    if f(v, i) then
      table.insert(ret, i)
    end
  end
  return ret
end

local function map(t, f)
  local ret = {}
  for i, v in ipairs(t) do
    table.insert(ret, f(v, i))
  end
  return ret
end

local function any(t, f)
  for i, v in ipairs(t) do
    if f(v, i) then
      return true
    end
  end
  return false
end

local function all(t, f)
  for i, v in ipairs(t) do
    if not f(v, i) then
      return false
    end
  end
  return true
end

local function find(t, f)
  for i, v in ipairs(t) do
    if f(v, i) then
      return v
    end
  end
  return nil
end

local function zip(a, b)
  local ret = {}
  for i = 1, math.max(#a, #b) do
    ret[i] = {a[i], b[i]}
  end
  return ret
end

function string.trim(self)
  -- for some reason the viml trim() function is _much_ faster than the lua one
  return v.nvim_call_function("trim", {self})
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
  local addl = length - v.nvim_call_function("strdisplaywidth", {s})
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
  for i = 1, addl do
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

return {
  filter = filter,
  map = map,
  any = any,
  all = all,
  find = find,
  zip = zip
}
