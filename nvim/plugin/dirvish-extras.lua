local api = vim.api

local function toggle()
  local bufs = vim.tbl_filter(function(buf)
    return api.nvim_buf_is_loaded(buf)
  end, api.nvim_list_bufs())
  local dirvish_bufs = {}
  for _, id in ipairs(bufs) do
    if vim.bo[id].filetype == "dirvish" then
      table.insert(dirvish_bufs, id)
    end
  end
  if #dirvish_bufs == 0 then
    vim.cmd("topleft 35vsp +Dirvish")
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
  vim.keymap.set(
    "n",
    "<C-r>",
    "<Cmd>Dirvish %<CR>",
    { buffer = true, silent = true }
  )
  vim.keymap.set("n", "<CR>", open, { buffer = true, silent = true })
  vim.keymap.set("n", "q", toggle, { buffer = true, silent = true })
  vim.cmd("silent! keeppatterns " .. [[g@\v/\.[^\/]+/?$@d]])
  for _, pat in ipairs(vim.o.wildignore:split(",")) do
    vim.cmd([[silent! keeppatterns g@\v/ ]] .. pat .. "/?$@d")
  end
end

api.nvim_create_autocmd("FileType", {
  pattern = "dirvish",
  callback = autocmds,
  group = api.nvim_create_augroup("dirvish-extras", {}),
})
vim.keymap.set(
  "n",
  "<Plug>(dirvish-toggle)",
  toggle,
  { silent = true, remap = true }
)
