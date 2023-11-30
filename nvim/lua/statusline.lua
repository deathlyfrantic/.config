local utils = require("utils")

local M = {}

local separator = "%1*│%*"
local error_block = "%2*■%*"
local warning_block = "%3*■%*"

---@return string
function M.filename()
  local bufname = vim.api.nvim_buf_get_name(0)
  if #bufname > 0 then
    return vim.fs.normalize(bufname):gsub(vim.loop.os_homedir(), "~")
  end
  return "cwd: " .. vim.loop.cwd():gsub(vim.loop.os_homedir(), "~")
end

-- this function is not used directly in this file but is passed to gitsigns as
-- the `status_formatter` function in its config
---@param status Gitsigns.StatusObj
---@return string
function M.gitsigns_status(status)
  local ret = status and status.head
  if not ret or ret == "" then
    return ""
  end
  local change_text = ""
  local function append_if_nonzero(symbol, change)
    if (change or 0) > 0 then
      change_text = change_text .. symbol .. change
    end
  end
  append_if_nonzero("+", status.added)
  append_if_nonzero("~", status.changed)
  append_if_nonzero("-", status.removed)
  return ("%s%s%s"):format(ret, #change_text > 0 and "/" or "", change_text)
end

-- Count of warning and error diagnostics in buffer
---@return string
function M.diagnostics()
  local warnings =
    #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local errors =
    #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  return errors + warnings == 0 and ""
    or (" %s %s%s%s"):format(
      separator,
      errors > 0 and error_block .. " " .. errors or "",
      errors > 0 and warnings > 0 and " " or "",
      warnings > 0 and warning_block .. " " .. warnings or ""
    )
end

-- Name of node under cursor from treesitter (if available)
---@return string
function M.treesitter()
  local ok, result = pcall(vim.treesitter.get_node)
  return ok and result and result:type() or ""
end

-- Create highlights for diagnostic error/warning blocks and for separator lines
local function set_highlights()
  -- separator line ┃│
  local fg = utils.get_hex_color("Normal", "bg")
  local bg = utils.get_hex_color("StatusLine", "bg")
  vim.api.nvim_set_hl(0, "User1", { fg = fg, bg = bg })
  -- ale warning + error blocks ●■
  local error_fg = utils.get_hex_color("Error", "fg")
  local warning_fg = utils.get_hex_color("Warning", "fg")
  vim.api.nvim_set_hl(0, "User2", { fg = error_fg, bg = bg })
  vim.api.nvim_set_hl(0, "User3", { fg = warning_fg, bg = bg })
end

---@param item string
---@return string
local function group(item)
  return "%(" .. item .. "%)"
end

---@param item string
---@return string
local function right_section(item)
  return group((" %s %s"):format(separator, item))
end

---@param item string
---@return string
local function left_section(item)
  return group(("%s %s "):format(item, separator))
end

-- Creates statusline-specific highlights and sets statusline option.
function M.init()
  set_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = set_highlights,
    group = vim.api.nvim_create_augroup("statusline-colorscheme-reset", {}),
  })
  vim.opt.statusline =
    -- buffer number
    left_section(" %n")
    -- filename
    .. left_section("%{v:lua.require('statusline').filename()}")
    .. "%<"
    -- gitsigns status
    .. left_section("%{get(b:, 'gitsigns_status', '')}")
    -- help buffer flag
    .. left_section("%{&bt == 'help' ? 'help' : ''}")
    -- modified flag
    .. left_section("%{!&ma ? '-' : &mod ? '+' : ''}")
    -- readonly flag
    .. left_section("%{&ro ? 'readonly' : ''}")
    -- show file format if not unix
    .. left_section("%{&ff != 'unix' ? &ff : ''}")
    -- show file encoding if not utf-8
    .. left_section("%{&fenc != 'utf-8' ? &fenc : ''}")
    -- separator
    .. "%="
    -- treesitter node type
    .. right_section("%{v:lua.require('statusline').treesitter()}")
    -- ale warnings/errors - section created manually because including
    -- highlights in %{} sections gets messy
    .. "%{%v:lua.require('statusline').diagnostics()%}"
    -- show wrap if it is on
    .. right_section("%{&wrap ? 'wrap' : ''}")
    -- session tracking via obsession
    .. right_section("%{ObsessionStatus('$', 'S')}")
    -- line, column, virtual column if different
    .. right_section("L%l C%c%V")
    -- percentage through file
    .. right_section("%3P ")
end

return M
