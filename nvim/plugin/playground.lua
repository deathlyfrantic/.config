local TermWindow = require("term-window")

local term_windows = {}

---@type { [string]: Ground }
local grounds = {
  ---@class Ground
  ---@field extension string
  ---@field command string
  ---@field template? string
  c = {
    extension = "c",
    command = "cc %s -o $TMPDIR/a.out && $TMPDIR/a.out",
    template = [[
      #include <stdio.h>
      #include <stdlib.h>
      #include <string.h>

      int main(void) {
          $$$
          return EXIT_SUCCESS;
      }]],
  },
  rust = {
    extension = "rs",
    command = "rustc %s -o $TMPDIR/a.out && $TMPDIR/a.out",
    template = [[
      fn main() {
          $$$
      }]],
  },
  python = {
    extension = "py",
    command = "python3 %s",
  },
  javascript = {
    extension = "js",
    command = "node %s",
  },
  lua = {
    extension = "lua",
    command = "luajit %s",
  },
  go = {
    extension = "go",
    command = "go run %s",
    template = [[
      package main

      import (
      	"fmt"
      )

      func main() {
      	$$$
      }]],
  },
}

---@param buf integer
---@param cmd string
local function run(buf, cmd)
  if not term_windows[buf] then
    term_windows[buf] = TermWindow({
      height_fn = function()
        return math.floor(math.min(vim.api.nvim_win_get_height(0) / 3, 15))
      end,
      location = "botright",
    })
    term_windows[buf]:on("BufDelete", function()
      term_windows[buf] = nil
    end)
  end
  term_windows[buf]:run(cmd)
end

---@param template string[]
---@return integer[]?
local function find_marker(template)
  for row, line in ipairs(template) do
    local col = line:find(vim.pesc("$$$"))
    if col then
      return { row, col - 2 }
    end
  end
end

---@param ground Ground
local function open_buffer(ground)
  local filename = vim.fn.tempname() .. "." .. ground.extension
  vim.cmd.edit(filename)
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = buf,
    callback = function()
      run(buf, ground.command:format(vim.api.nvim_buf_get_name(buf)))
    end,
  })
  vim.api.nvim_create_autocmd("BufDelete", {
    buffer = buf,
    callback = function()
      if term_windows[buf] then
        term_windows[buf]:close()
      end
      vim.uv.fs_unlink(filename)
    end,
  })
  local template = (ground.template or ""):dedent():splitlines()
  local cursor_pos = find_marker(template) or { 1, 0 }
  template = vim.tbl_map(function(line)
    return line:gsub(vim.pesc("$$$"), "")
  end, template)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, template)
  vim.api.nvim_win_set_cursor(0, cursor_pos)
  vim.api.nvim_input("a")
end

---@param args { args: string }
local function playground(args)
  local filetype = #args.args > 0 and args.args or vim.bo.filetype
  if not filetype or filetype == "" then
    vim.notify("No filetype specified", vim.log.levels.ERROR)
    return
  end
  local ground = grounds[filetype]
  if not ground then
    vim.notify(
      'No playground information found for filetype "' .. filetype .. '"',
      vim.log.levels.ERROR
    )
    return
  end
  open_buffer(ground)
end

---@param arglead string
---@return string[]
local function completion(arglead)
  return vim.tbl_filter(function(g)
    return g:starts_with(arglead)
  end, vim.tbl_keys(grounds))
end

vim.api.nvim_create_user_command(
  "Playground",
  playground,
  { complete = completion, nargs = "?" }
)
