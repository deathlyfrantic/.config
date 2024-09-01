local utils = require("utils")

local M = {}

---@param prompt string
---@param default string
---@param callback fun(string?): nil
local function prompt_for_input(prompt, default, callback)
  local prompt_pieces = prompt:split("\n", { trimempty = false })
  -- 3 below is 2 for separators and 1 for input line
  local height = math.min(#prompt_pieces + 3, math.floor(vim.o.lines - 10))
  local width = math.floor(
    math.min(
      math.max(utils.longest(default, prompt_pieces), vim.o.columns / 3),
      vim.o.columns - 10
    )
  )
  local opts = {
    relative = "editor",
    style = "minimal",
    border = "single",
    height = height,
    width = width,
    row = math.floor(vim.o.lines / 2) - math.floor(height / 2) - 2,
    col = math.floor(vim.o.columns / 2) - math.floor(width / 2) - 1,
    anchor = "NW",
    noautocmd = true,
  }
  -- prompt window
  local prompt_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, prompt_pieces)
  local prompt_win_id = vim.api.nvim_open_win(
    prompt_buf,
    true,
    vim.tbl_extend("force", opts, { height = #prompt_pieces })
  )
  if #prompt_pieces == 1 then
    vim.cmd.center({ args = { width } })
  end
  vim.bo[prompt_buf].modifiable = false
  vim.api.nvim_win_set_hl_ns(
    prompt_win_id,
    vim.api.nvim_create_namespace("popup-window")
  )
  -- input window
  local input_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, { default })
  local input_win_id = vim.api.nvim_open_win(
    input_buf,
    true,
    vim.tbl_extend("force", opts, {
      height = 1,
      relative = "win",
      win = prompt_win_id,
      row = #prompt_pieces + 1,
      col = -1,
    })
  )
  vim.api.nvim_win_set_hl_ns(
    input_win_id,
    vim.api.nvim_create_namespace("popup-window")
  )
  -- start insert mode
  vim.api.nvim_feedkeys("A", "n", false)
  local close = function()
    -- leave insert mode
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
    vim.api.nvim_win_close(prompt_win_id, true)
    vim.api.nvim_win_close(input_win_id, true)
  end
  local abort = function()
    close()
    callback(nil)
  end
  vim.keymap.set("i", "<Esc>", abort, { silent = true, buffer = input_buf })
  vim.keymap.set("i", "<C-c>", abort, { silent = true, buffer = input_buf })
  vim.keymap.set({ "n", "i" }, "<CR>", function()
    local line = vim.api.nvim_get_current_line()
    close()
    callback(line)
  end, { silent = true, buffer = input_buf })
end

---@param opts table?
---@param on_confirm fun(string?): nil
function M.input(opts, on_confirm)
  vim.validate({
    opts = { opts, "table", true },
    on_confirm = { on_confirm, "function" },
  })
  opts = opts or {}
  local prompt = opts.prompt or "Input:"
  local default = opts.default or ""
  prompt_for_input(prompt, default, on_confirm)
end

return M
