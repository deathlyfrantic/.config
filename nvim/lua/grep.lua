local utils = require("utils")

local M = {}

-- Perform a search and populate the quickfix list with the results. If no
-- results are found, quickfix list is not opened, and a "no results found"
-- message is printed.
---@param needle string
---@param bang boolean?
function M.search(needle, bang)
  vim.cmd(
    "silent grep! "
      .. needle:gsub("#", [[\#]]):gsub([[%%]], [[\%%]]):gsub("'", [['\'']])
  )
  if #vim.fn.getqflist() == 0 then
    vim.cmd.redraw({ bang = true })
    vim.notify("No matches found.", vim.log.levels.INFO)
  else
    vim.cmd.copen(bang and {
      mods = { split = "topleft", vertical = true },
      range = { math.floor(vim.o.columns / 3) },
    } or {
      mods = { split = "botright" },
    })
    vim.w.quickfix_title = ([[grep "%s"]]):format(needle)
    -- easy refresh
    vim.keymap.set("n", "R", function()
      M.search(needle, bang)
    end, { buffer = true })
  end
end

M.operator = utils.make_operator_fn(function(search)
  M.search(search, false)
end)

-- ripgrep-specific setup that should only be performed if `rg` is present
local function rg_init()
  local sort_cmd = "sort -t ':' -k1,1f -k2,2g -k3,3g"
  local ignores = vim
    .iter(vim.o.wildignore:split(","))
    :map(function(v)
      return ("-g '!%s'"):format(v)
    end)
    :join(" ")
  vim.o.grepprg = ("rg -F -S -H --no-heading --vimgrep %s -- '$*' \\| %s"):format(
    ignores,
    sort_cmd
  )
  vim.o.grepformat = "%f:%l:%c:%m"
  -- :Rg command variant allows passing arbitrary flags to ripgrep and doesn't
  -- default to -F (fixed-strings) option to allow regex searching
  vim.api.nvim_create_user_command("Rg", function(args)
    local saved_grepprg = vim.opt_local.grepprg:get()
    vim.opt_local.grepprg = "rg -H --no-heading --vimgrep -- $* \\| "
      .. sort_cmd
    M.search(args.args, args.bang)
    vim.opt_local.grepprg = saved_grepprg
  end, { bang = true, nargs = "+" })
end

function M.init()
  if vim.fn.executable("rg") == 1 then
    rg_init()
  end
  vim.api.nvim_create_user_command("Grep", function(args)
    M.search(args.args, args.bang)
  end, { bang = true, nargs = "+" })
  vim.keymap.set("n", "g/", ":Grep ")
  vim.keymap.set("n", "g/%", ":Grep <C-r>=expand('%:p:t:r')<CR><CR>")
  vim.keymap.set("n", "gs", function()
    vim.o.opfunc = "v:lua.require'grep'.operator"
    return "g@"
  end, { expr = true, silent = true })
  vim.keymap.set(
    "x",
    "gs",
    -- below line is required because of mode-switching behavior of operators,
    -- can't use a regular lua function
    "<Cmd>call v:lua.require'grep'.operator(mode())<CR>",
    { silent = true }
  )
end

return M
