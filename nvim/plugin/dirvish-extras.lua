local api = vim.api
local z = require("z")
local autocmd = require("autocmd")

local autocmd_handle

local function toggle()
  local bufs = vim.tbl_filter(
    function(buf)
      return api.nvim_buf_is_loaded(buf)
    end,
    api.nvim_list_bufs()
  )
  local dirvish_bufs = {}
  for _, id in ipairs(bufs) do
    if vim.bo[id].filetype == "dirvish" then
      table.insert(dirvish_bufs, id)
    end
  end
  if #dirvish_bufs == 0 then
    vim.cmd("35vsp +Dirvish")
  else
    vim.cmd("bdelete! " .. table.concat(dirvish_bufs, " "))
  end
end

local function open()
  local line = api.nvim_get_current_line()
  if line:match("/$") ~= nil then
    vim.fn["dirvish#open"]("edit", 0)
  else
    toggle()
    vim.cmd("edit " .. line)
  end
end

local function autocmds()
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.statusline = "%F"
  api.nvim_buf_set_keymap(
    0,
    "n",
    "<C-r>",
    "<Cmd>Dirvish %<CR>",
    { silent = true, noremap = true }
  )
  api.nvim_buf_set_keymap(
    0,
    "n",
    "<CR>",
    [[<Cmd>lua dirvish_extras.open()<CR>]],
    { silent = true, noremap = true }
  )
  api.nvim_buf_set_keymap(
    0,
    "n",
    "q",
    [[<Cmd>lua dirvish_extras.toggle()<CR>]],
    { silent = true, noremap = true }
  )
  vim.cmd("silent! keeppatterns " .. [[g@\v/\.[^\/]+/?$@d]])
  for _, pat in ipairs(vim.o.wildignore:split(",")) do
    vim.cmd([[silent! keeppatterns g@\v/ ]] .. pat .. "/?$@d")
  end
end

if autocmd_handle == nil then
  autocmd.add("FileType", "dirvish", autocmds)
end
vim.api.nvim_set_keymap(
  "n",
  "<Plug>(dirvish-toggle)",
  [[<Cmd>lua dirvish_extras.toggle()<CR>]],
  { silent = true }
)

_G.dirvish_extras = {
  toggle = toggle,
  open = open,
}
