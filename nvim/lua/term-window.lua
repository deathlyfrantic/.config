---@class TermWindow
---@field callbacks { [string]: function[] }
---@field buffer integer?
---@field window integer?
---@field close_on_success boolean
---@field location "botright" | "topleft"
---@field height_fn fun(): integer
local TermWindow = {}
TermWindow.__index = TermWindow

local default_config = {
  height_fn = function()
    return math.floor(vim.o.lines / 3)
  end,
  location = "botright",
  close_on_success = false,
}

-- Create a new terminal window
---@param config { close_on_success?: boolean, location?: "botright" | "topleft", height_fn?: fun(): integer }?
---@return TermWindow
function TermWindow.new(config)
  vim.validate({
    config = { config, "table", true },
  })
  return setmetatable(
    vim.tbl_extend(
      "force",
      -- start with default config
      default_config,
      -- layer specific config over top
      config or {},
      -- then ensure `buffer` and `callbacks` are always correctly initiated.
      -- `buffer = nil` here doesn't actually wipe out `buffer` if it exists,
      -- but I'm leaving it for reference.
      { buffer = nil, callbacks = {} }
    ),
    TermWindow
  )
end

---@alias TermWindowEvent
---| "Exit"      # fired when command exits
---| "BufAdd"    # fired when terminal buffer is created
---| "BufDelete" # fired when terminal buffer is deleted
---| "WinNew"    # fired when terminal window is created

---@param event TermWindowEvent
---@param ... any
function TermWindow.do_event(self, event, ...)
  if not self.callbacks[event] then
    return
  end
  for _, callback in ipairs(self.callbacks[event]) do
    callback(...)
  end
end

---@param event TermWindowEvent
---@param callback function
function TermWindow.on(self, event, callback)
  if type(self.callbacks[event]) ~= "table" then
    self.callbacks[event] = {}
  end
  table.insert(self.callbacks[event], callback)
end

function TermWindow.scroll_to_end(self)
  local current_window = vim.api.nvim_get_current_win()
  for _, win in
    ipairs(vim.tbl_filter(function(w)
      return vim.api.nvim_win_get_buf(w) == self.buffer
    end, vim.api.nvim_list_wins()))
  do
    vim.api.nvim_set_current_win(win)
    vim.cmd.normal("G")
  end
  vim.api.nvim_set_current_win(current_window)
end

function TermWindow.delete_buffer(self)
  if vim.api.nvim_buf_is_valid(self.buffer) then
    vim.api.nvim_buf_delete(self.buffer, { force = true })
  end
end

function TermWindow.on_exit(self, ...)
  local _, exit_code = ...
  self:scroll_to_end()
  self:do_event("Exit", ...)
  if self.close_on_success and exit_code == 0 then
    vim.defer_fn(function()
      self:delete_buffer()
    end, 1000)
  end
end

function TermWindow.load_or_create_buffer(self)
  if not self.buffer or not vim.api.nvim_buf_is_valid(self.buffer) then
    self.buffer = vim.api.nvim_create_buf(false, false)
    self:do_event("BufAdd")
    vim.bo[self.buffer].buftype = "nofile"
    vim.bo[self.buffer].modifiable = false
    vim.api.nvim_create_autocmd("BufDelete", {
      buffer = self.buffer,
      callback = function()
        self:do_event("BufDelete")
        self.buffer = nil
      end,
    })
    vim.keymap.set("n", "q", function()
      self:close()
    end, { buffer = self.buffer, silent = true })
  end
  vim.api.nvim_set_current_buf(self.buffer)
end

function TermWindow.close(self)
  self:delete_buffer()
  if vim.api.nvim_win_is_valid(self.window) then
    vim.api.nvim_win_close(self.window, true)
  end
end

function TermWindow.open(self)
  local wins = vim.tbl_filter(function(w)
    return vim.api.nvim_win_get_buf(w) == self.buffer
  end, vim.api.nvim_list_wins())
  if #wins == 0 then
    vim.cmd.split({
      mods = { split = self.location },
      range = { self.height_fn() },
    })
    self.window = vim.api.nvim_get_current_win()
    self:do_event("WinNew")
    self:load_or_create_buffer()
  else
    vim.api.nvim_set_current_win(wins[1])
  end
end

---@param cmd string
function TermWindow.run(self, cmd)
  local current_window = vim.api.nvim_get_current_win()
  self:open()
  vim.bo[self.buffer].modified = false
  vim.fn.termopen(cmd, {
    on_exit = function(...)
      self:on_exit(...)
    end,
  })
  vim.api.nvim_set_current_win(current_window)
end

return setmetatable({}, {
  ---@param config { close_on_success?: boolean, location?: "botright" | "topleft", height_fn?: fun(): integer }?
  ---@return TermWindow
  __call = function(_, config)
    return TermWindow.new(config)
  end,
  __index = TermWindow,
})
