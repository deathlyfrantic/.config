local z = require("z")

local handlers = {}
local _id = 0

local function next_id()
  _id = _id + 1
  return _id
end

local function _callback(id)
  local callback = handlers[id].callback
  if type(callback) == "function" then
    callback()
  else
    return vim.api.nvim_err_writeln("can't find callback with id " .. id)
  end
end

local function del(id)
  if handlers[id] ~= nil then
    augroup = handlers[id].augroup
    handlers[id] = nil
    vim.cmd(string.format(
      [[augroup %s 
        autocmd! 
      augroup END]],
      augroup
    ))
    if
      not z.any(handlers, function(handler)
        return handler.augroup == augroup
      end)
    then
      vim.cmd("augroup! " .. augroup)
    end
  end
end

-- options can contain:
-- - `once` - boolean - for ++once
-- - `nested` - boolean - for ++nested
-- - `augroup` - string - to customize the augroup name
local function add(event, pattern, callback, options)
  local id = next_id()
  options = options or {}
  local augroup = options.augroup or "autocmd.lua-" .. id
  local once
  if options.once then
    once = "++once"
    handlers[id] = {
      callback = function()
        callback()
        del(id)
      end,
      augroup = augroup,
    }
  else
    handlers[id] = { callback = callback, augroup = augroup }
  end
  local nested
  if options.nested then
    nested = "++nested"
  end
  vim.cmd("augroup " .. augroup)
  vim.cmd(string.format(
    [[autocmd %s %s %s %s lua require("autocmd")._callback(%s)]],
    event,
    pattern,
    once or "",
    nested or "",
    id
  ))
  vim.cmd("augroup END")
  return id
end

local function augroup(name, f)
  local local_add = function(event, pattern, callback, options)
    options = options or {}
    options.augroup = name
    add(event, pattern, callback, options)
  end
  f(local_add)
end

return {
  add = add,
  del = del,
  augroup = augroup,
  _callback = _callback,
}
