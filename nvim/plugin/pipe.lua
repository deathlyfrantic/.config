local function operator(kind)
  local selsave = vim.o.selection
  vim.o.selection = "inclusive"
  if kind ~= "v" and kind ~= "V" and kind ~= "" then
    vim.cmd("silent execute 'normal! `[v`]'")
  end
  local equalprg = vim.o.equalprg
  vim.o.equalprg = vim.fn.input("$ ", "", "shellcmd")
  vim.cmd("silent normal! =")
  vim.o.selection = selsave
  vim.o.equalprg = equalprg
end

_G.pipe = { operator = operator }

vim.api.nvim_set_keymap(
  "n",
  "g|",
  ":set opfunc=v:lua.pipe.operator<CR>g@",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "x",
  "g|",
  "<Cmd>call v:lua.pipe.operator(mode())<CR>",
  { noremap = true, silent = true }
)
