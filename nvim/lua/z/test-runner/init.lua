local api = vim.api

local test_buffer

local test_runners = {
  javascript = require("z.test-runner.javascript").test,
  make = require("z.test-runner.makefile").test,
  rust = require("z.test-runner.rust").test,
  typescript = require("z.test-runner.javascript").test,
}

local function scroll_to_end()
  local current_window = api.nvim_get_current_win()
  for _, w in ipairs(vim.fn.win_findbuf(test_buffer)) do
    api.nvim_set_current_win(w)
    vim.cmd.normal("G")
  end
  api.nvim_set_current_win(current_window)
end

local function on_exit(...)
  local close, _, exit_code = select(1, ...)
  if exit_code == 0 then
    if close then
      vim.defer_fn(function()
        if api.nvim_buf_is_valid(test_buffer) then
          api.nvim_buf_delete(test_buffer, { force = true })
        end
      end, 1000)
    end
    api.nvim_echo(
      { { "Tests pass. (Test runner exit code was 0.)", "Success" } },
      false,
      {}
    )
  else
    scroll_to_end()
  end
end

-- function body declared below - this is a hack to avoid circular dependencies
local rerun

local function load_or_create_buffer()
  if test_buffer ~= nil and api.nvim_buf_is_valid(test_buffer) then
    api.nvim_set_current_buf(test_buffer)
  else
    test_buffer = api.nvim_create_buf(false, false)
    vim.bo[test_buffer].buftype = "nofile"
    vim.bo[test_buffer].modifiable = false
    api.nvim_set_current_buf(test_buffer)
    api.nvim_create_autocmd("BufDelete", {
      buffer = test_buffer,
      callback = function()
        test_buffer = nil
      end,
    })
    vim.keymap.set(
      "n",
      "q",
      ":bd!<CR>",
      { buffer = test_buffer, silent = true }
    )
    vim.keymap.set("n", "R", rerun, { buffer = test_buffer, silent = true })
  end
end

local function new_test_window()
  local height = math.floor(vim.o.lines / 3)
  vim.cmd("botright " .. height .. "split")
  load_or_create_buffer()
end

local function ensure_test_window()
  if #vim.fn.win_findbuf(test_buffer) < 1 then
    new_test_window()
  end
end

local function run_tests(cmd, close)
  ensure_test_window()
  api.nvim_set_current_win(vim.fn.win_findbuf(test_buffer)[1])
  vim.b.command = cmd
  vim.b.close = close
  vim.bo.modified = false
  vim.fn.termopen(cmd, {
    on_exit = function(...)
      on_exit(close, ...)
    end,
  })
  scroll_to_end()
end

rerun = function()
  vim.bo[test_buffer].modified = false
  vim.bo[test_buffer].modifiable = true
  local close = vim.b.close
  if close == nil then
    close = true
  end
  run_tests(vim.b.command, close)
end

local function test(selection, force)
  local test_cmds, errs = {}, {}
  local filetype = vim.bo.filetype
  if type(vim.b.test_command) == "string" then
    table.insert(test_cmds, vim.b.test_command)
  elseif
    type(vim.b.test_command) == "table"
    and vim.b.test_command[selection] ~= nil
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
        api.nvim_exec("echo b:test_command." .. selection .. "()", true)
      )
    end
  elseif test_runners[filetype] ~= nil then
    local cmd = test_runners[filetype](selection)
    if cmd ~= nil then
      table.insert(test_cmds, cmd)
    end
  else
    table.insert(
      errs,
      string.format("No tests available for filetype '%s'", filetype)
    )
  end
  local maketest = test_runners.make()
  if maketest ~= nil then
    table.insert(test_cmds, maketest)
  else
    table.insert(errs, "no `Makefile` found")
  end
  local current_window = api.nvim_get_current_win()
  if #test_cmds > 0 then
    run_tests(test_cmds[1], force)
  else
    api.nvim_err_writeln(table.concat(errs, " and "))
  end
  api.nvim_set_current_win(current_window)
end

return {
  test = test,
  -- expose this for use in local config files etc
  find_nearest_test = require("z.test-runner.utils").find_nearest_test,
}
