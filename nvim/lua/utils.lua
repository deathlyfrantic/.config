local M = {}

-- Create a popup window at the cursor with the given text
---@param text any
---@param window_opts? table
---@return integer
function M.popup(text, window_opts)
  local buf = vim.api.nvim_create_buf(false, true)
  local contents
  if type(text) == "table" then
    contents = text
  elseif type(text) == "string" then
    contents = text:splitlines()
  else
    contents = { tostring(text) }
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, contents)
  local default_opts = {
    relative = "cursor",
    height = #contents,
    style = "minimal",
    focusable = false,
    width = M.longest(contents),
    anchor = "",
    border = "solid",
  }
  if vim.fn.screenrow() > (vim.o.lines / 2) then
    default_opts.anchor = default_opts.anchor .. "S"
    default_opts.row = 0
  else
    default_opts.anchor = default_opts.anchor .. "N"
    default_opts.row = 1
  end
  if vim.fn.screencol() > (vim.o.columns / 2) then
    default_opts.anchor = default_opts.anchor .. "E"
    default_opts.col = 0
  else
    default_opts.anchor = default_opts.anchor .. "W"
    default_opts.col = 1
  end
  local opts = vim.tbl_extend("force", default_opts, window_opts or {})
  local win = vim.api.nvim_open_win(buf, false, opts)
  vim.wo[win].colorcolumn = "0"
  return win
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
  all = {
    ".git",
  },
  go = {
    "go.sum",
    "go.mod",
  },
  javascript = {
    "package.json",
    "package-lock.json",
    "yarn.lock",
    "node_modules",
  },
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
  typescript = {
    "package.json",
    "package-lock.json",
    "yarn.lock",
    "tsconfig.json",
    "node_modules",
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
  if not start then
    local bufname = vim.api.nvim_buf_get_name(0)
    start = bufname:is_empty() and vim.uv.cwd() or bufname
  end
  local markers = vim.deepcopy(project_dir_markers[vim.bo.filetype] or {})
  vim.list_extend(markers, project_dir_markers.all)
  vim.b.z_project_dir = (vim.fs.root(start, markers) or vim.uv.cwd()) .. "/"
  return vim.b.z_project_dir
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
    return vim.iter(vim.fn.synstack(line, column)):any(function(id)
      return vim.fn.synIDattr(vim.fn.synIDtrans(id), "name"):imatch(pattern)
    end)
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
    contents = contents:splitlines()
  end
  local help_win = vim.iter(vim.api.nvim_list_wins()):find(function(win)
    return vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "help"
  end)
  if not help_win then
    vim.api.nvim_open_win(0, true, { win = 0, split = "above" })
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
  vim.api.nvim_set_current_win(help_win)
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

-- Given a list of strings, return the length of the longest one.
---@param ... string[] | string
---@return number
function M.longest(...)
  return vim
    .iter({ ... })
    :flatten(math.huge)
    :map(vim.fn.strdisplaywidth)
    :fold(-math.huge, math.max)
end

return M
