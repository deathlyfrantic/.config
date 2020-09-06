local nvim = require("nvim")

local function close_floating_windows()
  for _, id in ipairs(nvim.list_wins()) do
    if nvim.win_get_config(id).relative ~= "" then
      nvim.win_close(id, true)
    end
  end
end

return {
  close_floating_windows = close_floating_windows
}
