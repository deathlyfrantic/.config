local z = require("z")

local function grep(args)
  vim.cmd(
    "silent grep! "
      .. args.args
        :gsub("#", [[\#]])
        :gsub(vim.pesc("%"), [[\%]])
        :gsub("'", [['\'']])
  )
  local num_results = #vim.fn.getqflist()
  if num_results == 0 then
    vim.cmd.redraw({ bang = true })
    vim.notify("No matches found.", vim.log.levels.INFO)
  else
    if args.bang then
      vim.cmd("topleft vertical copen " .. math.floor(vim.o.columns / 3))
    else
      vim.cmd("botright copen " .. math.min(num_results, 10))
    end
    vim.w.quickfix_title = ([[grep "%s"]]):format(args.args)
    -- easy refresh
    vim.keymap.set("n", "R", function()
      grep(args)
    end, { buffer = true })
  end
end

_G.grep = {
  operator = z.make_operator_fn(function(search)
    grep({ args = search, bang = false })
  end),
}

local sort_cmd = "sort -t ':' -k1,1f -k2,2g -k3,3g"

if vim.fn.executable("rg") == 1 then
  local ignores = table.concat(
    vim.tbl_map(function(v)
      return ("-g '!%s'"):format(v)
    end, vim.o.wildignore:split(",")),
    " "
  )
  vim.o.grepprg = ("rg -F -S -H --no-heading --vimgrep %s '$*' \\| %s"):format(
    ignores,
    sort_cmd
  )
  vim.o.grepformat = "%f:%l:%c:%m"

  -- :Rg command variant allows passing arbitrary flags to ripgrep and doesn't
  -- default to -F (fixed-strings) option to allow regex searching
  local function rg(args)
    local saved_grepprg = vim.opt_local.grepprg:get()
    vim.opt_local.grepprg = "rg -H --no-heading --vimgrep $* \\| " .. sort_cmd
    grep(args)
    vim.opt_local.grepprg = saved_grepprg
  end
  vim.api.nvim_create_user_command("Rg", rg, { bang = true, nargs = "+" })
end

vim.api.nvim_create_user_command("Grep", grep, { bang = true, nargs = "+" })

vim.keymap.set("n", "g/", ":Grep ")
vim.keymap.set("n", "g/%", ":Grep <C-r>=expand('%:p:t:r')<CR><CR>")
vim.keymap.set(
  "n",
  "gs",
  ":set opfunc=v:lua.grep.operator<CR>g@",
  { silent = true }
)
vim.keymap.set(
  "x",
  "gs",
  "<Cmd>call v:lua.grep.operator(mode())<CR>",
  { silent = true }
)
