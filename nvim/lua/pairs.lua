-- "pairs" mappings inspired by https://github.com/tpope/vim-unimpaired/
local M = {}

-- exchange lines/hunks
---@param f function
local function move_lines(f)
  local foldmethod = vim.wo.foldmethod
  vim.wo.foldmethod = "manual"
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_set_mark(0, "`", cursor[1], cursor[2], {})
  f()
  vim.api.nvim_win_set_cursor(0, vim.api.nvim_buf_get_mark(0, "`"))
  vim.wo.foldmethod = foldmethod
end

---@param down boolean?
function M.visual_move_lines(down)
  move_lines(function()
    vim.cmd.move({
      args = { (down and "'>+" or "'<--") .. vim.v.count1 },
      range = {
        vim.api.nvim_buf_get_mark(0, "<")[1],
        vim.api.nvim_buf_get_mark(0, ">")[1],
      },
    })
  end)
end

-- option toggles
---@param key string
---@param option string
local function map_toggle(key, option)
  vim.keymap.set("n", "yo" .. key, function()
    vim.o[option] = not vim.o[option]
  end, { silent = true })
end

function M.init()
  -- move lines in normal mode
  for k, v in pairs({ ["[e"] = "--", ["]e"] = "+" }) do
    vim.keymap.set("n", k, function()
      move_lines(function()
        vim.cmd.move({ args = { v .. vim.v.count1 } })
      end)
    end, { silent = true })
  end

  -- move lines in visual mode
  for k, v in pairs({ ["[e"] = "v:false", ["]e"] = "v:true" }) do
    vim.keymap.set(
      "x",
      k,
      (":<C-u>call v:lua.require'pairs'.visual_move_lines(%s)<CR>"):format(v),
      { silent = true }
    )
  end

  -- option toggles
  map_toggle("C", "cursorcolumn")
  map_toggle("c", "cursorline")
  map_toggle("n", "number")
  map_toggle("r", "relativenumber")
  map_toggle("s", "spell")
  map_toggle("w", "wrap")
  vim.keymap.set("n", "yox", function()
    local state = vim.o.cursorline and vim.o.cursorcolumn
    vim.o.cursorline = not state
    vim.o.cursorcolumn = not state
  end, { silent = true })
end

return M
