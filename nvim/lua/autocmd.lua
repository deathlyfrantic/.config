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
    return vim.api.nvim_err_writeln("can't find callback with id " .. id)
  end
end

local function del(id)
  if handlers[id] ~= nil then
    aug_id = aug(id)
    handlers[id] = nil
    vim.cmd(([[
      augroup %s
        autocmd!
      augroup END
      augroup! %s
      ]]):format(aug_id, aug_id))
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
      del(id)
    end
  else
    once = nil
    handlers[id] = callback
  end
  vim.cmd("augroup " .. aug(id))
  vim.cmd(([[autocmd %s %s %s lua require("autocmd")._callback(%s)]]):format(event, pattern, once or "", id))
  vim.cmd("augroup END")
  return id
end

return {
  add = add,
  del = del,
  _callback = _callback,
}
