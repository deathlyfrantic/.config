local test = require("z.test-runner").test

local setups = {
  { "RunNearestTest", "t", "nearest" },
  { "RunTestFile", "T", "file" },
  { "RunTestSuite", "<C-t>", "all" },
}

for _, setup in ipairs(setups) do
  local cmd, key, param = unpack(setup)
  vim.api.nvim_create_user_command(cmd, function(args)
    test(param, not args.bang)
  end, { bang = true })
  vim.keymap.set(
    "n",
    "<leader>" .. key,
    ":" .. cmd .. "<CR>",
    { silent = true }
  )
  vim.keymap.set(
    "n",
    "g<leader>" .. key,
    ":" .. cmd .. "!<CR>",
    { silent = true }
  )
end
