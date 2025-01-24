---@param vertical boolean
local function quickfix_toggle(vertical)
  if
    vim.iter(vim.api.nvim_list_bufs()):any(function(b)
      return vim.bo[b].filetype == "qf" and vim.bo[b].buflisted
    end)
  then
    vim.cmd.cclose()
    return
  end
  vim.cmd.copen(vertical and {
    mods = { split = "topleft", vertical = true },
    range = { math.floor(vim.o.columns / 3) },
  } or { mods = { split = "botright" } })
end

vim.keymap.set("n", "<leader>q", quickfix_toggle, { silent = true })
vim.keymap.set("n", "<leader>Q", function()
  quickfix_toggle(true)
end, { silent = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function(args)
    vim
      .iter(vim.api.nvim_list_wins())
      :filter(function(win_id)
        return vim.api.nvim_win_get_buf(win_id) == args.buf
          -- don't want to set the height of a vertical quickfix window so use
          -- current height <= 10 as a proxy for whether the window is vertical
          and vim.api.nvim_win_get_height(win_id) <= 10
      end)
      :each(function(win_id)
        vim.api.nvim_win_set_height(win_id, math.min(10, #vim.fn.getqflist()))
      end)
    for _, key in ipairs({ "q", "<C-c>" }) do
      vim.keymap.set("n", key, vim.cmd.cclose, { buffer = true, silent = true })
    end
    vim.opt_local.wrap = false
  end,
  group = vim.api.nvim_create_augroup("quickfix", {}),
})
