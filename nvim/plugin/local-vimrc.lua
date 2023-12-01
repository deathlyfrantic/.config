-- local settings
---@param file string
---@param buf integer
---@param force? boolean
local function source_local_vimrc(file, buf, force)
  if
    not force
    and (
      file:starts_with("fugitive://")
      or vim.tbl_contains({ "help", "nofile" }, vim.bo[buf].buftype)
    )
  then
    return
  end
  -- apply settings from lowest dir to highest, so most specific are applied last
  local vimrcs = vim.fs.find(".vimrc.lua", {
    path = vim.fs.dirname(file),
    upward = true,
    stop = vim.loop.os_homedir(),
    limit = math.huge,
    type = "file",
  })
  for i = #vimrcs, 1, -1 do
    vim.cmd.source({
      args = { vimrcs[i] },
      mods = { emsg_silent = true, silent = true },
    })
  end
end

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost", "VimEnter" }, {
  pattern = "*",
  callback = function(args)
    -- force sourcing on VimEnter so empty buffers get local settings
    source_local_vimrc(args.match, args.buf, args.event == "VimEnter")
  end,
  nested = true,
  group = vim.api.nvim_create_augroup("local-vimrc", {}),
})
