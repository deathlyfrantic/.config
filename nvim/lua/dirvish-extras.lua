local nvim = require("nvim")
local z = require("z")
local autocmd = require("autocmd")

local function toggle()
  local bufs =
    z.filter(
    nvim.list_bufs(),
    function(buf)
      return nvim.buf_is_loaded(buf)
    end
  )
  local dirvish_bufs = {}
  for _, id in ipairs(bufs) do
    if nvim.bo[id].filetype == "dirvish" then
      table.insert(dirvish_bufs, id)
    end
  end
  if #dirvish_bufs == 0 then
    nvim.command("35vsp +Dirvish")
  else
    nvim.ex.bdelete_(table.concat(dirvish_bufs, " "))
  end
end

local function open()
  local line = nvim.get_current_line()
  if line:match("/$") ~= nil then
    nvim.fn.call("dirvish#open", {"edit", 0})
  else
    toggle()
    nvim.ex.edit(line)
  end
end

local function autocmds()
  nvim.wo.number = false
  nvim.wo.relativenumber = false
  nvim.wo.statusline = "%F"
  nvim.buf_set_keymap(
    0,
    "n",
    "<C-r>",
    "<Cmd>Dirvish %<CR>",
    {silent = true, noremap = true}
  )
  nvim.buf_set_keymap(
    0,
    "n",
    "<CR>",
    [[<Cmd>lua require("dirvish-extras").open()<CR>]],
    {silent = true, noremap = true}
  )
  nvim.buf_set_keymap(
    0,
    "n",
    "q",
    [[<Cmd>lua require("dirvish-extras").toggle()<CR>]],
    {silent = true, noremap = true}
  )
  nvim.ex.silent_("keeppatterns", [[g@\v/\.[^\/]+/?$@d]])
  for _, pat in ipairs(nvim.o.wildignore:split(",")) do
    nvim.ex.silent_("keeppatterns", [[g@\v/]] .. pat .. "/?$@d")
  end
end

local function init()
  autocmd.add("FileType", "dirvish", autocmds)
  nvim.set_keymap(
    "n",
    "<Plug>(dirvish-toggle)",
    [[<Cmd>lua require("dirvish-extras").toggle()<CR>]],
    {silent = true}
  )
end

return {
  toggle = toggle,
  open = open,
  init = init
}
