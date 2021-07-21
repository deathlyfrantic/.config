local api = vim.api

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
    ret[i] = { a[i], b[i] }
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

local function popup(text)
  local buf = api.nvim_create_buf(false, true)
  local array
  if type(text) == "table" then
    array = text
  elseif type(text) == "string" then
    array = text:split("\n")
  else
    array = { tostring(text) }
  end
  local contents = vim.tbl_map(function(line)
    return " " .. line .. " "
  end, array)
  table.insert(contents, 1, "")
  table.insert(contents, "")
  api.nvim_buf_set_lines(buf, 0, -1, true, contents)
  local opts = {
    relative = "cursor",
    height = #contents,
    style = "minimal",
    focusable = false,
    width = math.max(unpack(vim.tbl_map(string.len, contents))),
    anchor = "",
    border = "solid",
  }
  if vim.fn.screenrow() > (vim.o.lines / 2) then
    opts.anchor = opts.anchor .. "S"
    opts.row = 0
  else
    opts.anchor = opts.anchor .. "N"
    opts.row = 1
  end
  if vim.fn.screencol() > (vim.o.columns / 2) then
    opts.anchor = opts.anchor .. "E"
    opts.col = 0
  else
    opts.anchor = opts.anchor .. "W"
    opts.col = 1
  end
  local win = api.nvim_open_win(buf, false, opts)
  vim.wo[win].colorcolumn = "0"
  return win
end

-- like require() but reloads file every time so i don't have to restart nvim
-- to test changes
local function include(name)
  local path = package.searchpath(name, package.path)
  if path == nil then
    api.nvim_err_writeln(("Can't find %s.lua in package.path"):format(name))
    return
  end
  return loadfile(path)()
end

local function to_array(item)
  if type(item) ~= "table" then
    return { item }
  end
  return item
end

local function collect(iter, stop)
  local i = 0
  local ret = {}
  for v in iter do
    table.insert(ret, v)
    i = i + 1
    if stop ~= nil and i >= stop then
      break
    end
  end
  return ret
end

local function get_hex_color(hl, attr)
  local colors = api.nvim_get_hl_by_name(hl, true)
  local dec = colors.background
  if attr == "fg" or attr == "foreground" then
    dec = colors.foreground
  end
  return ("#%06x"):format(dec)
end

local function find_project_dir(...)
  local markers = {
    "Cargo.toml",
    "Cargo.lock",
    "node_modules",
    "package.json",
    "package-lock.json",
    "yarn.lock",
    ".git",
  }
  local function isdirectory(d)
    return vim.fn.isdirectory(d) == 1
  end
  local function filereadable(f)
    return vim.fn.filereadable(f) == 1
  end
  local fnamemodify = vim.fn.fnamemodify
  local expand = function(path)
    return vim.fn.expand(path, true)
  end
  local start = vim.fn.getcwd()
  if select("#", ...) > 0 then
    start = ...
  end
  local dir = start
  while dir ~= expand("~") and dir ~= "/" do
    local path = dir .. "/"
    if
      any(markers, function(d)
        return isdirectory(expand(path .. d))
          or filereadable(expand(path .. d))
      end)
    then
      return fnamemodify(dir, ":p")
    end
    dir = fnamemodify(dir, ":h")
    if dir == "." then
      return fnamemodify(dir, ":p")
    end
  end
  return fnamemodify(dir, ":p")
end

local function buf_is_real(b)
  return api.nvim_buf_is_valid(b)
    and api.nvim_buf_is_loaded(b)
    and vim.bo[b].buflisted
end

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
  any = any,
  all = all,
  find = find,
  zip = zip,
  tbl_reverse = tbl_reverse,
  popup = popup,
  include = include,
  to_array = to_array,
  collect = collect,
  get_hex_color = get_hex_color,
  find_project_dir = find_project_dir,
  buf_is_real = buf_is_real,
}
