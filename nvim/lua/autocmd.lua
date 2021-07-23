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
    local augroup = handlers[id].augroup
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

local function autocmds_are_equal(a, b)
  return a.event == b.event
    and a.pattern == b.pattern
    and string.dump(a.callback) == string.dump(b.callback)
    and a.once == b.once
    and a.nested == b.nested
    and a.augroup == b.augroup
end

local function already_added(a)
  return z.any(handlers, function(b)
    return autocmds_are_equal(a, b)
  end)
end

local function add(id, event, pattern, callback, options)
  local autocmd = {
    event = event,
    pattern = pattern,
    callback = callback,
    once = options.once,
    nested = options.nested,
    augroup = options.augroup,
  }
  local once, nested
  if options.once then
    once = "++once"
    autocmd.callback = function()
      callback()
      del(id)
    end
  end
  -- `unique` should default to true, we almost never want to add a duplicate
  -- autocmd
  if (options.unique == nil or options.unique) and already_added(autocmd) then
    return
  end
  handlers[id] = autocmd
  if options.nested then
    nested = "++nested"
  end
  vim.cmd(
    string.format(
      [[autocmd %s %s %s %s lua require("autocmd")._callback(%s)]],
      event,
      pattern,
      once or "",
      nested or "",
      id
    )
  )
  return id
end

-- options can contain:
-- - `once` - boolean - for ++once
-- - `nested` - boolean - for ++nested
-- - `augroup` - string - to customize the augroup name
-- - `unique` - boolean - prevents autocmd being added again if all attributes
--   match an existing autocmd
local function wrap_in_augroup(name, f)
  vim.cmd("augroup " .. name)
  local ret = f()
  vim.cmd("augroup END")
  return ret
end

local function add_in_augroup(event, pattern, callback, options)
  local id = next_id()
  options = options or {}
  options.augroup = options.augroup or "autocmd.lua-" .. id
  return wrap_in_augroup(options.augroup, function()
    return add(id, event, pattern, callback, options)
  end)
end

local function augroup(name, f)
  local local_add = function(event, pattern, callback, options)
    options = options or {}
    options.augroup = name
    add(next_id(), event, pattern, callback, options)
  end
  wrap_in_augroup(name, function()
    return f(local_add)
  end)
end

return {
  add = add_in_augroup,
  del = del,
  augroup = augroup,
  _callback = _callback,
}
