local api = vim.api

local mt = {
  test_buffer = nil,
  runners = {
    javascript = require("z.test-runner.javascript").test,
    make = require("z.test-runner.makefile").test,
    python = require("z.test-runner.python").test,
    rust = require("z.test-runner.rust").test,
    typescript = require("z.test-runner.javascript").test,
  },
}
mt.__index = mt
local TestRunner = {}
setmetatable(TestRunner, mt)

function TestRunner.scroll_to_end(self)
  local current_window = api.nvim_get_current_win()
  for _, w in ipairs(vim.fn.win_findbuf(self.test_buffer)) do
    api.nvim_set_current_win(w)
    vim.cmd.normal("G")
  end
  api.nvim_set_current_win(current_window)
end

function TestRunner.on_exit(self, ...)
  local close, _, exit_code = select(1, ...)
  if exit_code == 0 then
    if close then
      vim.defer_fn(function()
        if api.nvim_buf_is_valid(self.test_buffer) then
          api.nvim_buf_delete(self.test_buffer, { force = true })
        end
      end, 1000)
    end
    api.nvim_echo(
      { { "Tests pass. (Test runner exit code was 0.)", "Success" } },
      false,
      {}
    )
  else
    self:scroll_to_end()
  end
end

-- function body declared below - this is a hack to avoid circular dependencies
function TestRunner.rerun(self)
  vim.bo[self.test_buffer].modified = false
  vim.bo[self.test_buffer].modifiable = true
  local close = vim.b.close
  if close == nil then
    close = true
  end
  self:run(vim.b.command, close)
end

function TestRunner.load_or_create_buffer(self)
  if self.test_buffer ~= nil and api.nvim_buf_is_valid(self.test_buffer) then
    api.nvim_set_current_buf(self.test_buffer)
  else
    self.test_buffer = api.nvim_create_buf(false, false)
    vim.bo[self.test_buffer].buftype = "nofile"
    vim.bo[self.test_buffer].modifiable = false
    api.nvim_set_current_buf(self.test_buffer)
    api.nvim_create_autocmd("BufDelete", {
      buffer = self.test_buffer,
      callback = function()
        self.test_buffer = nil
      end,
    })
    vim.keymap.set(
      "n",
      "q",
      ":bd!<CR>",
      { buffer = self.test_buffer, silent = true }
    )
    vim.keymap.set("n", "R", function()
      self:rerun()
    end, { buffer = self.test_buffer, silent = true })
  end
end

function TestRunner.new_test_window(self)
  local height = math.floor(vim.o.lines / 3)
  vim.cmd("botright " .. height .. "split")
  self:load_or_create_buffer()
end

function TestRunner.ensure_test_window(self)
  if #vim.fn.win_findbuf(self.test_buffer) < 1 then
    self:new_test_window()
  end
end

function TestRunner.run(self, cmd, close)
  self:ensure_test_window()
  api.nvim_set_current_win(vim.fn.win_findbuf(self.test_buffer)[1])
  vim.b.command = cmd
  vim.b.close = close
  vim.bo.modified = false
  vim.fn.termopen(cmd, {
    on_exit = function(...)
      self:on_exit(close, ...)
    end,
  })
  self:scroll_to_end()
end

function TestRunner.test(self, selection, force)
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
  elseif self.runners[filetype] ~= nil then
    local cmd = self.runners[filetype](selection)
    if cmd ~= nil then
      table.insert(test_cmds, cmd)
    end
  else
    table.insert(
      errs,
      string.format("No tests available for filetype '%s'", filetype)
    )
  end
  local maketest = self.runners.make()
  if maketest ~= nil then
    table.insert(test_cmds, maketest)
  else
    table.insert(errs, "no `Makefile` found")
  end
  local current_window = api.nvim_get_current_win()
  if #test_cmds > 0 then
    self:run(test_cmds[1], force)
  else
    api.nvim_err_writeln(table.concat(errs, " and "))
  end
  api.nvim_set_current_win(current_window)
end

return {
  test = function(...)
    TestRunner:test(...)
  end,
  -- expose this for use in local config files etc
  find_nearest_test = require("z.test-runner.utils").find_nearest_test,
}
