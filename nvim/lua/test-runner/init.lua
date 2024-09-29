local TermWindow = require("term-window")

local M = {}

---@type TermWindow?
local term_window = nil

local runners = {
  javascript = require("test-runner.javascript").test,
  make = require("test-runner.makefile").test,
  python = require("test-runner.python").test,
  rust = require("test-runner.rust").test,
  typescript = require("test-runner.javascript").test,
  go = require("test-runner.go").test,
}

---@param cmd string
---@param close boolean
local function run(cmd, close)
  if not term_window then
    term_window = TermWindow({ close_on_success = close }) --[[@as TermWindow]]
    term_window:on("Exit", function(_, exit_code)
      if exit_code == 0 then
        vim.notify("Tests pass. (Test runner exit code was 0.)")
      end
    end)
    term_window:on("BufDelete", function()
      term_window = nil
    end)
    term_window:on("BufAdd", function()
      local buf = term_window.buffer
      vim.b[buf].cmd = cmd
      vim.keymap.set("n", "R", function()
        -- rerun the tests
        vim.bo[buf].modified = false
        vim.bo[buf].modifiable = true
        run(vim.b[buf].cmd, term_window.close_on_success)
      end, { buffer = buf, silent = true })
    end)
  else
    -- do this here in case we're reusing the TermWindow for another test
    term_window.close_on_success = close
    if vim.api.nvim_buf_is_valid(term_window.buffer) then
      vim.b[term_window.buffer].cmd = cmd
    end
  end
  term_window:run(cmd)
end

---@alias TestRunnerSelection
---| "all"     # run entire test suite
---| "file"    # run all tests in the file
---| "nearest" # run the tesst nearest to the cursor

---@param selection TestRunnerSelection
---@param close boolean
local function test(selection, close)
  local test_cmds, errs = {}, {}
  local filetype = vim.bo.filetype
  if type(vim.b.test_command) == "string" then
    table.insert(test_cmds, vim.b.test_command)
  elseif
    type(vim.b.test_command) == "table" and vim.b.test_command[selection]
  then
    if type(vim.b.test_command[selection]) == "string" then
      table.insert(test_cmds, vim.b.test_command[selection])
    else
      -- assuming this is a function here - doesn't make sense for it to be
      -- anything else. this is _insanity_ - there's no way to run a function
      -- stored in a buffer variable natively in lua, so we have to execute
      -- vimscript and echo the result, which we then capture as a string :oof:
      table.insert(
        test_cmds,
        vim.api.nvim_exec2(
          "echo b:test_command." .. selection .. "()",
          { output = true }
        ).output
      )
    end
  elseif runners[filetype] then
    local cmd = runners[filetype](selection)
    if cmd then
      table.insert(test_cmds, cmd)
    end
  else
    table.insert(errs, "No tests available for filetype '" .. filetype .. "'")
  end
  local maketest = runners.make()
  if maketest then
    table.insert(test_cmds, maketest)
  else
    table.insert(errs, "no `Makefile` found")
  end
  if #test_cmds > 0 then
    run(test_cmds[1], close)
  else
    vim.notify(table.concat(errs, " and "), vim.log.levels.ERROR)
  end
end

-- Initialize the test runner. Creates user commands and sets key maps for
-- running tests.
function M.init()
  -- run nearest test - command RunNearestTest, key t
  vim.api.nvim_create_user_command("RunNearestTest", function(args)
    test("nearest", not args.bang)
  end, { bang = true })
  vim.keymap.set("n", "<leader>t", ":RunNearestTest<CR>", { silent = true })
  vim.keymap.set("n", "g<leader>t", ":RunNearestTest!<CR>", { silent = true })
  -- run test file - command RunTestSuite, key T
  vim.api.nvim_create_user_command("RunTestFile", function(args)
    test("file", not args.bang)
  end, { bang = true })
  vim.keymap.set("n", "<leader>T", ":RunTestFile<CR>", { silent = true })
  vim.keymap.set("n", "g<leader>T", ":RunTestFile!<CR>", { silent = true })
  -- run all tests - command RunTestSuite, key <C-t>
  vim.api.nvim_create_user_command("RunTestSuite", function(args)
    test("all", not args.bang)
  end, { bang = true })
  vim.keymap.set("n", "<leader><C-t>", ":RunTestSuite<CR>", { silent = true })
  vim.keymap.set("n", "g<leader><C-t>", ":RunTestSuite!<CR>", { silent = true })
end

-- expose this for use in local config files etc
M.find_nearest_test = require("test-runner.utils").find_nearest_test

return M
