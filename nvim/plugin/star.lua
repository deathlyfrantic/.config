local api = vim.api
local autocmd = require("autocmd")
local z = require("z")

local file = vim.fn.tempname()
local buffer, star_cmd_str

local function height()
  return math.max(10, math.floor(vim.o.lines / 3))
end

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
    star_cmd_str = "star -m --height " .. height() .. " "
    for k, v in pairs(colors) do
      star_cmd_str = star_cmd_str .. ("--%s=%s "):format(k, v)
    end
  end
  return star_cmd_str
end

local function base_cmd()
  return string.format(
    "(cd %s && %%s | %s > %s)",
    z.find_project_dir(),
    star_cmd(),
    file
  )
end

local function files_cmd(mode)
  return base_cmd():format(find_cmd(mode))
end

local function buffers_cmd()
  local bufs = vim.tbl_map(
    function(b)
      return vim.fn.fnamemodify(api.nvim_buf_get_name(b), ":p:~:.")
    end,
    vim.tbl_filter(function(b)
      return z.buf_is_real(b) and api.nvim_buf_get_name(b) ~= ""
    end, api.nvim_list_bufs())
  )
  return base_cmd():format(([[echo "%s"]]):format(table.concat(bufs, "\n")))
end

local function open_buffer(b)
  if type(b) == "table" then
    b = b[1]
  end
  api.nvim_set_current_buf(
    vim.uri_to_bufnr(vim.uri_from_fname(vim.fn.fnamemodify(b, ":p")))
  )
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

local modes = {
  files = {
    cmd = function()
      return files_cmd("files")
    end,
    open = open_file,
  },
  buffers = { cmd = buffers_cmd, open = open_buffer },
  all = {
    cmd = function()
      return files_cmd("all")
    end,
    open = open_file,
  },
  git_commits = {
    cmd = function()
      return base_cmd():format(
        "git log --pretty=format:'%h%d :: %s [%cd - %an]' --date=format:'%d %b %Y' --no-merges"
      )
    end,
    open = function(paths)
      for _, commit in ipairs(paths) do
        vim.cmd("Git show " .. commit:match("^%x+"))
      end
    end,
    width_divisor = 2,
  },
}

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
      modes[mode].open(paths)
    end
  end
end

local function popup_window(buf, mode)
  local divisor = modes[mode].width_divisor or 3
  local width = math.max(80, math.floor(vim.o.columns / divisor))
  local opts = {
    relative = "editor",
    style = "minimal",
    border = "single",
    height = height(),
    width = width,
    row = math.floor(vim.o.lines / 2) - math.floor(height() / 2),
    col = math.floor(vim.o.columns / 2) - math.floor(width / 2),
    anchor = "NW",
  }
  api.nvim_open_win(buf, true, opts)
  vim.wo.winhl = "Normal:Normal,FloatBorder:Normal"
end

local function open_star_buffer(mode)
  -- need to look at vim.b.star_find_cmd in the current buffer before opening
  -- the star buffer where it will not be populated
  local term_cmd = modes[mode].cmd()
  local mode_text = find_cmd(mode)
  if mode == "buffers" then
    mode_text = "open buffers"
  end
  -- now open the star buffer
  buffer = api.nvim_create_buf(false, false)
  popup_window(buffer, mode)
  vim.bo[buffer].buftype = "nofile"
  vim.bo[buffer].modifiable = false
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
  local mode = ... or "files"
  if not vim.tbl_contains(vim.tbl_keys(modes), mode) then
    api.nvim_err_writeln(string.format("'%s' is not a valid mode", mode))
    return
  end
  open_star_buffer(mode)
end

local function completion(arglead)
  return vim.tbl_filter(function(m)
    return vim.startswith(m, arglead)
  end, vim.tbl_keys(modes))
end

autocmd.add("ColorScheme,VimResized", "*", function()
  star_cmd_str = nil
end, {
  augroup = "star-colorscheme-reset",
  unique = true,
})

vim.cmd(
  [[command! -nargs=? -complete=customlist,v:lua.star.completion Star call v:lua.star.star(<f-args>)]]
)
api.nvim_set_keymap("n", "<C-p>", ":Star files<CR>", {})
api.nvim_set_keymap("n", "g<C-p>", ":Star all<CR>", {})
api.nvim_set_keymap("n", "g<C-b>", ":Star buffers<CR>", {})
api.nvim_set_keymap("n", "g<C-g>", ":Star git_commits<CR>", {})

_G.star = { star = star, completion = completion }
