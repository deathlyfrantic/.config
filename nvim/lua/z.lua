local nvim = require("nvim")

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

local function tbl_reverse(t)
  local ret = {}
  local i = 1
  for j = #t, 1, -1 do
    ret[i] = t[j]
    i = i + 1
  end
  return ret
end

-- like require() but reloads file every time so i don't have to restart nvim
-- to test changes
local function include(name)
  local path = package.searchpath(name, package.path)
  if path == nil then
    nvim.err_writeln(("Can't find %s.lua in package.path"):format(name))
    return
  end
  return loadfile(path)()
end

local function to_array(item)
  if type(item) ~= "table" then
    return {item}
  end
  return item
end

function string.trim(self)
  -- for some reason the viml trim() function is _much_ faster than the lua one
  return nvim.fn.trim(self)
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

local function string_chars(s, i)
  if #s > i then
    i = i + 1
    return i, s:sub(i, i)
  end
end

function string.chars(self)
  return string_chars, self, 0
end

return {
  filter = filter,
  map = map,
  any = any,
  all = all,
  find = find,
  zip = zip,
  tbl_reverse = tbl_reverse,
  include = include,
  to_array = to_array
}
