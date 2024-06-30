local utils = require("utils")

local M = {}

---@type Notification[]
local notifications = {}

local id = -1

---@return integer
local function next_id()
  id = id + 1
  return id
end

---@alias log_levels 0 | 1 | 2 | 3 | 4 | 5

local level_highlights = {
  [vim.log.levels.ERROR] = "Error",
  [vim.log.levels.WARN] = "Warning",
}

local level_names = {
  [vim.log.levels.DEBUG] = "Debug",
  [vim.log.levels.ERROR] = "Error",
  [vim.log.levels.INFO] = "Info",
  [vim.log.levels.OFF] = "Off",
  [vim.log.levels.TRACE] = "Trace",
  [vim.log.levels.WARN] = "Warning",
}

---@class Notification
---@field id integer
---@field msg string
---@field lines fun(self): string[]
---@field level log_levels
---@field opts table
---@field title fun(self): string
---@field highlight fun(self): string
---@field height fun(self): integer
---@field width fun(self): integer
---@field timeout integer
---@field buf? integer
---@field win? integer
---@field close_timer? table
local Notification_mt = {
  lines = function(self)
    if self.msg:find("\n") then
      return self.msg:split("\n")
    end
    return { self.msg }
  end,
  title = function(self)
    return self.opts.title or level_names[self.level]
  end,
  highlight = function(self)
    return level_highlights[self.level] or "Normal"
  end,
  height = function(self)
    local num_lines = #self:lines()
    return num_lines > 1 and num_lines or math.ceil(#self.msg / self:width())
  end,
  width = function(self)
    return math.min(utils.longest(self:lines()), math.ceil(vim.o.columns / 4))
  end,
}
Notification_mt.__index = Notification_mt

---@param msg string
---@param level log_levels
---@param opts table
---@return Notification
local function Notification(msg, level, opts)
  return setmetatable({
    id = next_id(),
    msg = msg,
    level = level,
    opts = opts,
    timeout = opts.timeout or vim.o.updatetime,
  }, Notification_mt)
end

-- If a notification gets closed before the close timer fires, we need to ignore
-- it when placing other notifications. This function returns a list of
-- Notification objects whose windows are still valid.
---@return Notification[]
local function visible_notifications()
  return vim.tbl_filter(function(notification)
    return vim.api.nvim_win_is_valid(notification.win)
  end, notifications)
end

-- tabline.lua sets 'showtabline' based on visible buffers, so if the tabline
-- is not visible it is 0 or 1, if it is visible it is >= 2.
---@return integer
local function starting_row()
  return vim.o.showtabline < 2 and 1 or 2
end

---@return integer
local function find_starting_row()
  local visible = visible_notifications()
  if #visible == 0 then
    local row = starting_row()
    for _, notification in ipairs(visible_notifications()) do
      -- 2 for top and bottom borders, 1 for spacing between
      row = row + notification:height() + 3
    end
    return row
  end
  local win = visible[#visible].win
  local last_win_position = vim.api.nvim_win_get_position(win)
  local last_win_height = vim.api.nvim_win_get_height(win)
  return last_win_position[1] + last_win_height + 2
end

local function collapse_notifications()
  local row = starting_row()
  for _, notification in ipairs(visible_notifications()) do
    vim.api.nvim_win_set_config(notification.win, {
      relative = "editor",
      row = row,
      col = vim.o.columns - 1,
    })
    -- `nvim_win_set_config()` resets highlight namespace apparently?
    vim.api.nvim_win_set_hl_ns(
      notification.win,
      vim.api.nvim_create_namespace("popup-window")
    )
    row = row + notification:height() + 2
  end
end

---@param notification Notification
local function remove_notification(notification)
  if vim.api.nvim_win_is_valid(notification.win) then
    vim.api.nvim_win_close(notification.win, true)
  end
  notifications = vim.tbl_filter(function(n)
    return n.id ~= notification.id
  end, notifications)
  collapse_notifications()
end

---@param notification Notification
local function add_notification(notification)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, notification:lines())
  vim.bo[buf].modifiable = false
  local opts = {
    relative = "editor",
    style = "minimal",
    border = "single",
    height = notification:height(),
    width = notification:width(),
    row = find_starting_row(),
    col = vim.o.columns - 1,
    anchor = "NW",
    title = { { " " .. notification:title() .. " ", notification:highlight() } },
    title_pos = "right",
    noautocmd = true,
  }
  local win = vim.api.nvim_open_win(buf, false, opts)
  vim.api.nvim_win_set_hl_ns(win, vim.api.nvim_create_namespace("popup-window"))
  vim.wo[win].wrap = true
  notification.buf = buf
  notification.win = win
  notification.close_timer = vim.defer_fn(function()
    remove_notification(notification)
  end, notification.timeout)
  table.insert(notifications, notification)
end

---@param msg string
---@param level? log_levels
---@param opts table
function M.notify(msg, level, opts)
  vim.validate({
    msg = { msg, "string" },
    level = { level, "number", true },
    opts = { opts, "table", true },
  })
  level = level or vim.log.levels.INFO
  opts = opts or {}
  local notification = Notification(msg, level, opts)
  add_notification(notification)
end

return M
