local api = vim.api
local z = require("z")

vim.cmd("highlight! hl_word gui=underline cterm=underline")

local function save_window(f)
  local current_window = api.nvim_get_current_win()
  f()
  api.nvim_set_current_win(current_window)
end

local function clear()
  save_window(function()
    vim.cmd("windo 2match none")
  end)
end

local function toggle()
  local pat = ([[\<%s\>]]):format(vim.fn.expand("<cword>"))
  local col = api.nvim_win_get_cursor(0)[2] + 1
  local char = api.nvim_get_current_line():sub(col, col)
  if
    char:match("%s")
    or z.any(vim.fn.getmatches(), function(m)
      return m.group == "hl_word" and m.pattern == pat
    end)
  then
    clear()
  elseif char:match("%w") then
    save_window(function()
      vim.cmd("windo execute '2match hl_word /" .. pat .. "/'")
    end)
  end
end

_G.hlword = { toggle = toggle, clear = clear }

api.nvim_set_keymap(
  "n",
  "<C-Space>",
  "<Cmd>call v:lua.hlword.toggle()<CR>",
  { noremap = true, silent = true }
)
api.nvim_set_keymap(
  "n",
  "<Space>",
  [[:if v:hlsearch | execute 'nohlsearch | call v:lua.hlword.clear()' | else | call v:lua.hlword.toggle() | endif<CR>]],
  --  this ↑ can't be a function because `v:hlsearch` is reset when a function ends
  { noremap = true, silent = true }
)
