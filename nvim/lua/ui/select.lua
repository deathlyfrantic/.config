local M = {}

---@param choices string[]
---@param prompt string
---@param callback fun(index?: integer)
local function select_window(choices, prompt, callback)
  local prompt_pieces = prompt:split("\n", { trimempty = false })
  -- choice height + prompt height + separators
  local height =
    math.min(#choices + #prompt_pieces + 2, math.floor(vim.o.lines - 10))
  local longest = math.max(
    unpack(vim.tbl_map(string.len, choices)),
    unpack(vim.tbl_map(string.len, prompt_pieces))
  )
  local width = math.floor(math.min(longest, vim.o.columns - 10))
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
  vim.bo[prompt_buf].modifiable = false
  local prompt_win_id = vim.api.nvim_open_win(
    prompt_buf,
    false,
    vim.tbl_extend("force", opts, { height = #prompt_pieces })
  )
  vim.api.nvim_win_set_hl_ns(
    prompt_win_id,
    vim.api.nvim_create_namespace("popup-window")
  )
  -- choices window
  local choices_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(choices_buf, 0, -1, false, choices)
  vim.bo[choices_buf].modifiable = false
  local choices_win_id = vim.api.nvim_open_win(
    choices_buf,
    true,
    vim.tbl_extend("force", opts, {
      height = #choices,
      relative = "win",
      win = prompt_win_id,
      anchor = "NW",
      row = #prompt_pieces + 1,
      col = -1,
    })
  )
  vim.api.nvim_win_set_hl_ns(
    choices_win_id,
    vim.api.nvim_create_namespace("popup-window")
  )
  vim.wo[choices_win_id].cursorline = true
  local close = function()
    vim.api.nvim_win_close(prompt_win_id, true)
    vim.api.nvim_win_close(choices_win_id, true)
  end
  local abort = function()
    close()
    callback(nil)
  end
  vim.keymap.set("n", "q", abort, { silent = true, buffer = choices_buf })
  vim.keymap.set("n", "<Esc>", abort, { silent = true, buffer = choices_buf })
  vim.keymap.set("n", "<CR>", function()
    local line = vim.api.nvim_win_get_cursor(choices_win_id)[1]
    close()
    callback(line)
  end, { silent = true, buffer = choices_buf })
end

---@generic T
---@param items `T`[]
---@param opts { prompt?: string, format_item?: (fun(item: T): string), kind?: string }
---@param on_choice fun(item?: T, index?: integer)
function M.select(items, opts, on_choice)
  vim.validate({
    items = { items, "table" },
    opts = { opts, "table", true },
    on_choice = { on_choice, "function" },
  })
  opts = opts or {}
  local prompt = opts.prompt or "Select one of:"
  local format_item = opts.format_item or tostring
  select_window(vim.tbl_map(format_item, items), prompt, function(index)
    on_choice(items[index], index)
  end)
end

return M
