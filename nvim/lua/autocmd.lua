local nvim = require("nvim")

local handlers = {}
local _id = 0

local function aug(id)
  return "autocmd.lua-" .. id
end

local function next_id()
  _id = _id + 1
  return _id
end

local function _callback(id)
  local callback = handlers[id]
  if type(callback) == "function" then
    callback()
  else
    return nvim.err_writeln("can't find callback with id " .. id)
  end
end

local function del(id)
  if handlers[id] ~= nil then
    handlers[id] = nil
    nvim.ex.augroup(aug(id))
    nvim.ex.autocmd_()
    nvim.ex.augroup("END")
    nvim.ex.augroup_(aug(id))
  end
end

local function add(event, pattern, callback, options)
  local id = next_id()
  options = options or {}
  local once
  if options.once then
    once = "++once"
    handlers[id] = function()
      callback()
      handlers[id] = nil
    end
  else
    once = nil
    handlers[id] = callback
  end
  nvim.ex.augroup(aug(id))
  nvim.ex.autocmd(
    event,
    pattern,
    once or "",
    "lua",
    ([[require("autocmd")._callback(%s)]]):format(id)
  )
  nvim.ex.augroup("END")
  return id
end

return {
  add = add,
  del = del,
  _callback = _callback,
}
