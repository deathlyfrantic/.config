local M = {}

---@type table<string, function>
local overrides = {
  notify = require("ui.notify").notify,
  select = require("ui.select").select,
  input = require("ui.input").input,
}

---@type table<string, function>
local builtins = {}

function M.restore()
  for _, key in ipairs(vim.tbl_keys(overrides)) do
    if not builtins[key] then
      error(("Can't restore `%s`, builtin has not been saved."):format(key))
    end
  end
  vim.notify = builtins.notify
  vim.ui.select = builtins.select
  vim.ui.input = builtins.input
  builtins = {}
end

function M.save_builtins()
  builtins.notify = vim.notify
  builtins.select = vim.ui.select
  builtins.input = vim.ui.input
end

function M.override()
  vim.notify = overrides.notify
  vim.ui.select = overrides.select
  vim.ui.input = overrides.input
end

local valid_command_args = { "on", "off" }

---@param args { args: string }
local function ui_command(args)
  local cmd = args.args:lower()
  local msg = "Custom UI is now %s."
  if cmd == "off" then
    M.restore()
    vim.notify(msg:format("off", vim.log.levels.INFO))
  elseif cmd == "on" then
    M.override()
    vim.notify(msg:format("on", vim.log.levels.INFO))
  else
    vim.notify(
      ("Invalid argument '%s'; valid options are: %s"):format(
        args.args,
        table.concat(valid_command_args, ", ")
      ),
      vim.log.levels.ERROR
    )
  end
end

---@param arglead string
---@return string[]
local function completion(arglead)
  return vim.tbl_filter(function(cmd)
    return cmd:starts_with(arglead)
  end, valid_command_args)
end

function M.init()
  M.save_builtins()
  M.override()
  vim.api.nvim_create_user_command(
    "UI",
    ui_command,
    { nargs = 1, complete = completion }
  )
end

return M
