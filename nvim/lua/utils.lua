local M = {}

-- Returns true if f(item) is true for any item in a table
---@param f fun(v: any, i?: integer): boolean
---@param t any[]
---@return boolean
function M.tbl_any(f, t)
  for i, v in ipairs(t) do
    if f(v, i) then
      return true
    end
  end
  return false
end

-- Returns true if f(item) is true for all items in a table
---@param f fun(v: any, i?: integer): boolean
---@param t any[]
---@return boolean
function M.tbl_all(f, t)
  for i, v in ipairs(t) do
    if not f(v, i) then
      return false
    end
  end
  return true
end

-- Returns the item and index of the item of a table if f(item) is true
---@param f fun(v: any, i?: integer): boolean
---@param t any[]
---@return boolean?, integer?
function M.tbl_find(f, t)
  for i, v in ipairs(t) do
    if f(v, i) then
      return v, i
    end
  end
  return nil
end

-- Create a popup window at the cursor with the given text
---@param text any
---@param title string?
---@return integer
function M.popup(text, title)
  local buf = vim.api.nvim_create_buf(false, true)
  local contents
  if type(text) == "table" then
    contents = text
  elseif type(text) == "string" then
    contents = text:split("\n")
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

-- Collect items from an iterator into a table
---@generic T
---@param ... `T`
---@return T[]
function M.collect(...)
  local ret = {}
  for item in ... do
    table.insert(ret, item)
  end
  return ret
end

-- Get a standard hex color representation (#rrggbb) of a highlight
---@param hl string
---@param attr "fg" | "foreground" | "bg" | "background"
---@return string
function M.get_hex_color(hl, attr)
  local colors = vim.api.nvim_get_hl(0, { name = hl })
  while colors.link do
    colors = vim.api.nvim_get_hl(0, { name = colors.link })
  end
  local dec = (attr == "fg" or attr == "foreground") and colors.fg or colors.bg
  return ("#%06x"):format(dec)
end

local project_dir_markers = {
  python = {
    "mypy.ini",
    "poetry.lock",
    "pylintrc",
    "pyproject.toml",
    "requirements.txt",
    "setup.cfg",
    "setup.py",
    "tox.ini",
    ".mypy_cache",
    ".pytest_cache",
    ".tox",
  },
  rust = {
    "Cargo.toml",
    "Cargo.lock",
    "target",
  },
  javascript = {
    "package.json",
    "package-lock.json",
    "yarn.lock",
    "node_modules",
  },
  typescript = {
    "package.json",
    "package-lock.json",
    "yarn.lock",
    "tsconfig.json",
    "node_modules",
  },
  all = {
    ".git",
  },
}

-- Find project dir based on filetype-specific markers, optionally starting from
-- a provided directory
---@param start string?
---@return string
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
  local markers = vim.deepcopy(project_dir_markers[vim.bo.filetype] or {})
  vim.list_extend(markers, project_dir_markers.all)
  local paths = vim.fs.find(markers, {
    upward = true,
    stop = vim.loop.os_homedir(),
    path = start or vim.loop.cwd(),
  })
  if #paths > 0 then
    return cache(vim.fs.dirname(paths[1]) .. "/")
  end
  return cache(vim.loop.cwd() .. "/")
end

-- Determine whether a buffer is "real" i.e. valid, loaded and listed
---@param b integer
---@return boolean
function M.buf_is_real(b)
  return vim.api.nvim_buf_is_valid(b)
    and vim.api.nvim_buf_is_loaded(b)
    and vim.bo[b].buflisted
end

-- Get the character immediately before the cursor
---@return string
function M.char_before_cursor()
  local column = vim.api.nvim_win_get_cursor(0)[2]
  return column < 1 and ""
    or vim.api.nvim_get_current_line():sub(column, column)
end

-- Determine if the syntax highlighting at a position contains a pattern, e.g.
-- "is the cursor in a comment?"
---@param pattern string
---@param pos? integer[]
---@return boolean
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

-- Display arbitrary contents in a Vim help window
---@param contents string | table
function M.help(contents)
  if type(contents) == "string" then
    contents = contents:split("\n")
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

-- Handle the steps necessary to make `*` work in visual mode
---@param cmd string?
---@param raw boolean?
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

-- Make an operator function out of a callback
---@param callback fun(selection: string)
---@return fun(kind: string)
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
