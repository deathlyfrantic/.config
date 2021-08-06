local api = vim.api
local autocmd = require("autocmd")
local z = require("z")

local file = vim.fn.tempname()
local buffer, star_cmd_str

local function find_cmd(mode)
  if vim.b.star_find_cmd ~= nil then
    return vim.b.star_find_cmd
  end
  local open_files
  if mode == "all" then
    open_files = {}
  else
    local bufs = vim.tbl_filter(function(b)
      return z.buf_is_real(b) and api.nvim_buf_get_name(b) ~= ""
    end, api.nvim_list_bufs())
    open_files = vim.tbl_map(function(b)
      return vim.fn.fnamemodify(api.nvim_buf_get_name(b), ":p:~:.")
    end, bufs)
  end
  return ("rg --files %s"):format(table.concat(
    vim.tbl_map(function(f)
      return "-g !" .. vim.fn.shellescape(vim.fn.escape(f, " ["))
    end, open_files),
    " "
  ))
end

local function star_cmd()
  if star_cmd_str == nil then
    local colors = {
      ["color-selected-bg"] = z.get_hex_color("StatusLine", "bg"),
      ["color-matched-selected-fg"] = z.get_hex_color("Comment", "fg"),
      ["color-matched-fg"] = z.get_hex_color("String", "fg"),
      ["color-tag-fg"] = z.get_hex_color("WarningMsg", "bg"),
    }
    star_cmd_str = "star -m "
    for k, v in pairs(colors) do
      star_cmd_str = star_cmd_str .. ("--%s=%s "):format(k, v)
    end
  end
  return star_cmd_str
end

local function cmd(mode)
  local ret = string.format(
    "(cd %s && %%s | %s > %s)",
    z.find_project_dir(),
    star_cmd(),
    file
  )
  if mode == "files" or mode == "all" then
    return ret:format(find_cmd(mode))
  elseif mode == "buffers" then
    local bufs = vim.tbl_map(
      function(b)
        return vim.fn.fnamemodify(api.nvim_buf_get_name(b), ":p:~:.")
      end,
      vim.tbl_filter(function(b)
        return z.buf_is_real(b) and api.nvim_buf_get_name(b) ~= ""
      end, api.nvim_list_bufs())
    )
    return ret:format(([[echo "%s"]]):format(table.concat(bufs, "\n")))
  end
end

local function open_buffer(b)
  if type(b) == "table" then
    b = b[1]
  end
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if vim.endswith(api.nvim_buf_get_name(buf), b) then
      api.nvim_set_current_buf(buf)
    end
  end
end

local function open_file(files)
  local paths = vim.tbl_map(function(f)
    return vim.fn.escape(z.find_project_dir() .. f, " [")
  end, files)
  for i, f in ipairs(paths) do
    if vim.loop.fs_access(f, "r") then
      if i == 1 then
        vim.cmd("edit " .. f)
      else
        vim.cmd("badd " .. f)
      end
    end
  end
end

local function delete_buffer()
  api.nvim_buf_delete(buffer, { force = true })
  buffer = nil
end

local function on_exit(mode, _, exit_code)
  local previous_window = vim.fn.win_getid(vim.fn.winnr("#"))
  api.nvim_set_current_win(previous_window)
  if buffer ~= nil then
    delete_buffer()
  end
  if exit_code == 0 then
    if vim.loop.fs_access(file, "r") then
      local paths = z.collect(io.open(file):lines())
      if mode == "files" or mode == "all" then
        open_file(paths)
      else
        open_buffer(paths)
      end
    end
  end
end

local function open_star_buffer(mode)
  -- need to look at vim.b.star_find_cmd in the current buffer before opening
  -- the star buffer where it will not be populated
  local term_cmd = cmd(mode)
  local mode_text = find_cmd(mode)
  if mode == "buffers" then
    mode_text = "open buffers"
  end
  -- now open the star buffer
  local height = math.min(10, math.floor(vim.o.lines / 3))
  vim.cmd("botright " .. height .. "split")
  buffer = api.nvim_create_buf(false, false)
  vim.bo[buffer].buftype = "nofile"
  vim.bo[buffer].modifiable = false
  api.nvim_set_current_buf(buffer)
  vim.fn.termopen(term_cmd, {
    on_exit = function(...)
      on_exit(mode, ...)
    end,
  })
  local name = ("Star(%s)"):format(z.find_project_dir():sub(1, -2))
  vim.wo.statusline = ("[%s] %s"):format(name, mode_text)
  vim.b.term_title = name
  vim.cmd("startinsert")
end

local function star(...)
  local mode = "files"
  if select("#", ...) > 0 then
    mode = ...
  end
  open_star_buffer(mode)
end

local function completion()
  return { "all", "buffers", "files" }
end

autocmd.add("ColorScheme", "*", function()
  star_cmd_str = nil
end, {
  augroup = "star-colorscheme-reset",
  unique = true,
})

vim.cmd(
  [[command! -nargs=? -complete=customlist,v:lua.star.completion Star call v:lua.star.star(<f-args>)]]
)
api.nvim_set_keymap("n", "<C-p>", ":Star<CR>", {})
api.nvim_set_keymap("n", "g<C-p>", ":Star all<CR>", {})
api.nvim_set_keymap("n", "g<C-b>", ":Star buffers<CR>", {})

_G.star = { star = star, completion = completion }
