local M = {}

function M.init()
  require("text-objects.indent").init()
  require("text-objects.variable-segment").init()
  -- comment text object is built in, just remap it
  vim.keymap.set(
    { "o", "v" },
    "ic",
    [[:<C-u>lua require("vim._comment").textobject()<CR>]],
    { silent = true }
  )
end

return M
