local api = vim.api
local z = require("z")

local function close_floating_windows()
  for _, id in ipairs(api.nvim_list_wins()) do
    if api.nvim_win_get_config(id).relative ~= "" then
      api.nvim_win_close(id, true)
    end
  end
end

local function source_local_vimrc(bang)
  local is_fugitive = ("^fugitive://"):match(vim.fn.expand("<afile>"))
  local abuf = tonumber(vim.fn.expand("<abuf>"))
  if
    bang ~= "!"
    and (
      is_fugitive
      or vim.tbl_contains({ "help", "nofile" }, vim.bo[abuf].buftype)
    )
  then
    return
  end
  -- apply settings from lowest dir to highest, so most specific are applied last
  for _, vimrc in ipairs(z.tbl_reverse(vim.fn.findfile(".vimrc", vim.fn.expand("<afile>:p:h") .. ";", -1))) do
    vim.cmd("silent! source " .. vimrc)
  end
end

return {
  close_floating_windows = close_floating_windows,
  source_local_vimrc = source_local_vimrc,
}
