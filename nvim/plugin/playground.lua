local api = vim.api
local z = require("z")
local dedent = require("plenary.strings").dedent

local output_buffer = nil

local grounds = {
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
}

local function new_output_buffer()
  output_buffer = api.nvim_create_buf(false, false)
  api.nvim_set_current_buf(output_buffer)
  api.nvim_create_autocmd("BufDelete", {
    buffer = output_buffer,
    callback = function()
      output_buffer = nil
    end,
    once = true,
    group = api.nvim_create_augroup("playground-buf-delete", {}),
  })
  vim.keymap.set("n", "q", ":bd!<CR>", { buffer = true, silent = true })
end

local function load_or_create_buffer()
  if output_buffer ~= nil and api.nvim_buf_is_valid(output_buffer) then
    api.nvim_set_current_buf(output_buffer)
  else
    new_output_buffer()
    vim.cmd("normal G")
  end
end

local function new_window()
  local height = math.floor(math.min(api.nvim_win_get_height(0) / 3, 15))
  vim.cmd("belowright " .. height .. "split")
  load_or_create_buffer()
end

local function ensure_window()
  if
    not output_buffer
    or not z.any(api.nvim_list_wins(), function(w)
      return api.nvim_win_get_buf(w) == output_buffer
    end)
  then
    new_window()
  end
end

local function delete_output_buffer()
  if output_buffer ~= nil and api.nvim_buf_is_valid(output_buffer) then
    api.nvim_buf_delete(output_buffer, { force = true })
  end
  output_buffer = nil
end

local function scroll_to_end()
  local current_window = api.nvim_get_current_win()
  for _, w in
    ipairs(vim.tbl_filter(function(w)
      return api.nvim_win_get_buf(w) == output_buffer
    end, api.nvim_list_wins()))
  do
    api.nvim_set_current_win(w)
    vim.cmd("normal G")
  end
  api.nvim_set_current_win(current_window)
end

local function run(cmd)
  ensure_window()
  local current_window = api.nvim_get_current_win()
  local wins = vim.tbl_filter(function(w)
    return api.nvim_win_get_buf(w) == output_buffer
  end, api.nvim_list_wins())
  api.nvim_set_current_win(wins[1])
  vim.bo.modified = false
  vim.fn.termopen(cmd, { on_exit = scroll_to_end })
  api.nvim_set_current_win(current_window)
end

local function find_marker(template)
  local row = 1
  for _, line in ipairs(template) do
    local col = line:find(vim.pesc("$$$"))
    if col then
      return { row, col - 2 }
    end
    row = row + 1
  end
end

local function open_buffer(ground)
  local filename = vim.fn.tempname() .. "." .. ground.extension
  vim.cmd("edit " .. filename)
  local cmd = string.format(ground.command, vim.fn.getreg("%"))
  local bufnr = api.nvim_get_current_buf()
  local group = api.nvim_create_augroup("playground-bufnr-" .. bufnr, {})
  api.nvim_create_autocmd("BufWritePost", {
    buffer = bufnr,
    callback = function()
      run(cmd)
    end,
    group = group,
  })
  api.nvim_create_autocmd("BufDelete", {
    buffer = bufnr,
    callback = function()
      delete_output_buffer()
      vim.loop.fs_unlink(filename)
    end,
    group = group,
  })
  local template = dedent(ground.template or ""):split("\n")
  if template[1] == "" then
    table.remove(template, 1)
  end
  local cursor_pos = find_marker(template) or { 1, 0 }
  template = vim.tbl_map(function(line)
    return line:gsub(vim.pesc("$$$"), "")
  end, template)
  api.nvim_buf_set_lines(0, 0, 1, true, template)
  api.nvim_win_set_cursor(0, cursor_pos)
  api.nvim_input("a")
end

local function playground(args)
  local filetype = vim.bo.filetype
  if #args.args > 0 then
    filetype = args.args
  end
  if not filetype or filetype == "" then
    api.nvim_err_writeln("No filetype specified")
    return
  end
  local ground = grounds[filetype]
  if not ground then
    api.nvim_err_writeln(
      string.format(
        'No playground information found for filetype "%s"',
        filetype
      )
    )
    return
  end
  open_buffer(ground)
end

local function completion(arglead)
  return vim.tbl_filter(function(g)
    return vim.startswith(g, arglead)
  end, vim.tbl_keys(grounds))
end

api.nvim_create_user_command(
  "Playground",
  playground,
  { complete = completion, nargs = "?" }
)
