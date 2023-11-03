local M = {}

function M.tbl_any(f, t)
  for i, v in ipairs(t) do
    if f(v, i) then
      return true
    end
  end
  return false
end

function M.tbl_all(f, t)
  for i, v in ipairs(t) do
    if not f(v, i) then
      return false
    end
  end
  return true
end

function M.tbl_find(f, t)
  for i, v in ipairs(t) do
    if f(v, i) then
      return v, i
    end
  end
  return nil
end

function M.popup(text, title)
  local buf = vim.api.nvim_create_buf(false, true)
  local contents
  if type(text) == "table" then
    contents = text
  elseif type(text) == "string" then
    contents = text:split("\n", { plain = true, trimempty = true })
  else
    contents = { tostring(text) }
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, contents)
  local opts = {
    relative = "cursor",
    height = #contents,
    style = "minimal",
    focusable = false,
    width = math.max(unpack(vim.tbl_map(string.len, contents))),
    anchor = "",
    border = "solid",
    title = title,
    title_pos = title and "center" or nil,
  }
  if vim.fn.screenrow() > (vim.o.lines / 2) then
    opts.anchor = opts.anchor .. "S"
    opts.row = 0
  else
    opts.anchor = opts.anchor .. "N"
    opts.row = 1
  end
  if vim.fn.screencol() > (vim.o.columns / 2) then
    opts.anchor = opts.anchor .. "E"
    opts.col = 0
  else
    opts.anchor = opts.anchor .. "W"
    opts.col = 1
  end
  local win = vim.api.nvim_open_win(buf, false, opts)
  vim.wo[win].colorcolumn = "0"
  return win
end

function M.collect(...)
  local ret = {}
  for item in ... do
    table.insert(ret, item)
  end
  return ret
end

function M.get_hex_color(hl, attr)
  local colors = vim.api.nvim_get_hl(0, { name = hl })
  local dec = (attr == "fg" or attr == "foreground") and colors.fg or colors.bg
  return ("#%06x"):format(dec)
end

function M.find_project_dir(start)
  -- this should always be the same value for a given buffer, so cache the value
  -- as a buffer variable to prevent repeated walking of the file system
  if vim.b.z_project_dir then
    return vim.b.z_project_dir
  end
  local cache = function(value)
    vim.b.z_project_dir = value
    return value
  end
  local markers = {
    python = {
      files = {
        "mypy.ini",
        "poetry.lock",
        "pylintrc",
        "pyproject.toml",
        "requirements.txt",
        "setup.cfg",
        "setup.py",
        "tox.ini",
      },
      dirs = { ".mypy_cache", ".pytest_cache", ".tox" },
    },
    rust = {
      files = { "Cargo.toml", "Cargo.lock" },
      dirs = { "target" },
    },
    javascript = {
      files = { "package.json", "package-lock.json", "yarn.lock" },
      dirs = { "node_modules" },
    },
    typescript = {
      files = {
        "package.json",
        "package-lock.json",
        "yarn.lock",
        "tsconfig.json",
      },
      dirs = { "node_modules" },
    },
    all = {
      dirs = { ".git" },
    },
  }
  local files, dirs = {}, {}
  local ft_markers = markers[vim.bo.filetype]
  if ft_markers then
    vim.list_extend(files, ft_markers.files)
    vim.list_extend(dirs, ft_markers.dirs)
  end
  vim.list_extend(files, markers.all.files or {})
  vim.list_extend(dirs, markers.all.dirs or {})
  local dir = start or vim.loop.cwd()
  while dir ~= vim.fs.normalize("$HOME") and dir ~= "/" do
    if
      M.tbl_any(function(f)
        return vim.fn.filereadable(vim.fs.normalize(dir .. "/" .. f)) == 1
      end, files)
      or M.tbl_any(function(d)
        return vim.fn.isdirectory(vim.fs.normalize(dir .. "/" .. d)) == 1
      end, dirs)
    then
      return cache(vim.fs.normalize(dir) .. "/")
    end
    dir = vim.fs.dirname(dir)
  end
  return cache(vim.loop.cwd() .. "/")
end

function M.buf_is_real(b)
  return vim.api.nvim_buf_is_valid(b)
    and vim.api.nvim_buf_is_loaded(b)
    and vim.bo[b].buflisted
end

function M.char_before_cursor()
  local column = vim.api.nvim_win_get_cursor(0)[2]
  return column < 1 and ""
    or vim.api.nvim_get_current_line():sub(column, column)
end

function M.highlight_at_pos_contains(pattern, pos)
  if not pos then
    pos = vim.api.nvim_win_get_cursor(0)
    pos[2] = pos[2] - 1
  end
  local line, column = unpack(pos)
  -- if syntax is on that means treesitter highlighting is not enabled, so use
  -- vim regex highlighting
  if vim.bo.syntax ~= "" then
    return M.tbl_any(function(id)
      return vim.fn.synIDattr(vim.fn.synIDtrans(id), "name"):imatch(pattern)
    end, vim.fn.synstack(line, column))
  end
  -- if syntax isn't set then try to get node type from treesitter. treesitter
  -- uses 0-based indexing so subtract one from line and column.
  local ok, node = pcall(
    vim.treesitter.get_node,
    { bufnr = 0, pos = { line - 1, column - 1 } }
  )
  return ok and node:type():imatch(pattern)
end

function M.help(contents)
  if type(contents) == "string" then
    contents = contents:split("\n", { plain = true, trimempty = true })
  end
  local help_win = M.tbl_find(function(win)
    return vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "help"
  end, vim.api.nvim_list_wins())
  if not help_win then
    vim.cmd.split()
    help_win = vim.api.nvim_get_current_win()
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, contents)
  vim.bo[buf].buftype = "help"
  vim.bo[buf].filetype = "help"
  vim.bo[buf].readonly = true
  vim.bo[buf].modified = false
  vim.bo[buf].modifiable = false
  vim.api.nvim_win_set_buf(help_win, buf)
  if #contents < vim.api.nvim_win_get_height(help_win) then
    vim.api.nvim_win_set_height(help_win, #contents)
  end
end

function M.v_star_search_set(cmd, raw)
  cmd = cmd or "/"
  local temp = vim.fn.getreg('"')
  vim.cmd.normal({ args = { "gvy" }, bang = true })
  local search = vim.fn.getreg('"')
  if not raw then
    search = vim.fn.escape(search, cmd .. "\\*")
  end
  search = search
    :gsub("\n", "\\n")
    :gsub("%[", "\\[")
    :gsub("~", "\\~")
    :gsub("%.", "\\.")
    :gsub("%^", "\\^")
    :gsub("\22", [[\%%x16]]) -- ctrl-v
  vim.fn.setreg("/", search)
  vim.fn.setreg('"', temp)
end

function M.make_operator_fn(callback)
  local error_msg = function(msg)
    vim.notify(
      msg or "Multiline selections do not work with this operator",
      vim.log.levels.ERROR
    )
  end
  return function(kind)
    if kind:find("[V]") then
      error_msg()
      return
    end
    local regsave = vim.fn.getreg("@")
    local selsave = vim.o.selection
    vim.o.selection = "inclusive"
    if kind == "v" then
      vim.cmd.normal({ args = { "y" }, bang = true, mods = { silent = true } })
    else
      vim.cmd.normal({
        args = { "`[v`]y" },
        bang = true,
        mods = { silent = true },
      })
    end
    local selection = vim.fn.getreg("@")
    vim.o.selection = selsave
    vim.fn.setreg("@", regsave)
    if not selection or selection == "" then
      error_msg("No selection")
      return
    elseif selection:trim():find("\n") then
      error_msg()
      return
    end
    callback(selection)
  end
end

return M
