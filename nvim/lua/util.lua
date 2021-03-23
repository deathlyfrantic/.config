local nvim = require("nvim")
local z = require("z")

local function close_floating_windows()
  for _, id in ipairs(nvim.list_wins()) do
    if nvim.win_get_config(id).relative ~= "" then
      nvim.win_close(id, true)
    end
  end
end

local function source_local_vimrc(bang)
  local is_fugitive = ("^fugitive://"):match(nvim.fn.expand("<afile>"))
  local abuf = tonumber(nvim.fn.expand("<abuf>"))
  if
    bang ~= "!"
    and (
      is_fugitive
      or vim.tbl_contains({ "help", "nofile" }, nvim.bo[abuf].buftype)
    )
  then
    return
  end
  -- apply settings from lowest dir to highest, so most specific are applied last
  for _, vimrc in ipairs(z.tbl_reverse(nvim.fn.findfile(".vimrc", nvim.fn.expand("<afile>:p:h") .. ";", -1))) do
    nvim.ex.silent_("source", vimrc)
  end
end

return {
  close_floating_windows = close_floating_windows,
  source_local_vimrc = source_local_vimrc,
}
