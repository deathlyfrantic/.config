local M = {}

function M.filename()
  local bufname = vim.api.nvim_buf_get_name(0)
  if #bufname > 0 then
    return vim.fs.normalize(bufname):gsub(vim.fs.normalize("$HOME"), "~")
  end
  return ("[cwd: %s]"):format(
    vim.loop.cwd():gsub(vim.fs.normalize("$HOME"), "~")
  )
end

function M.treesitter()
  local ok, result = pcall(vim.treesitter.get_node)
  return ok and result and result:type() or ""
end

function M.init()
  vim.opt.statusline =
    -- buffer number and filename
    "[%n] %{v:lua.require('statusline').filename()}%<"
    -- gitsigns status, as defined by status_formatter in the package spec
    .. "%( %{get(b:, 'gitsigns_status', '')}%)"
    -- help buffer flag, modified flag, readonly flag
    .. "%( %h%)%( %m%)%( %r%)"
    -- show file format if not unix
    .. "%{&ff != 'unix' ? ' [' .. &ff .. ']' : ''}"
    -- show file encoding if not utf-8
    .. "%{len(&fenc) && &fenc != 'utf-8' ? ' [' .. &fenc .. ']' : ''}"
    -- separator
    .. "%="
    -- treesitter node type
    .. "%{v:lua.require('statusline').treesitter()}   "
    -- show wrap if it is on
    .. "%{&wrap ? '[wrap] ' : ''}"
    -- session tracking via obsession
    .. "%(%{ObsessionStatus()} %)"
    -- line, column, virtual column if different, percentage through file
    .. "  %l,%c%V%6P"
end

return M
