local api = vim.api

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
    vim.cmd("redraw!")
    api.nvim_echo({ { "No matches found." } }, false, {})
  else
    if args.bang then
      vim.cmd("topleft vertical copen " .. math.floor(vim.o.columns / 3))
    else
      vim.cmd("botright copen " .. math.min(num_results, 10))
    end
    vim.w.quickfix_title = string.format([[grep "%s"]], args.args)
  end
end

local function operator(kind)
  local error = function(msg)
    api.nvim_err_writeln(
      msg or "Multiline selections do not work with this operator"
    )
  end
  if kind:match("[V]") then
    error()
    return
  end
  local regsave = vim.fn.getreg("@")
  local selsave = vim.o.selection
  vim.o.selection = "inclusive"
  if kind == "v" then
    vim.cmd([[silent execute "normal! y"]])
  else
    vim.cmd([[silent execute "normal! `[v`]y"]])
  end
  local search = vim.fn.getreg("@")
  vim.o.selection = selsave
  vim.fn.setreg("@", regsave)
  if search:match("\n") then
    error()
    return
  elseif search == "" then
    error("No selection")
    return
  end
  grep({ args = search, bang = false })
end

_G.grep = { operator = operator }

local sort_cmd = "sort -t ':' -k1,1f -k2,2g -k3,3g"

if vim.fn.executable("rg") then
  local ignores = table.concat(
    vim.tbl_map(function(v)
      return string.format("-g '!%s'", v)
    end, vim.split(vim.o.wildignore, ",")),
    " "
  )
  vim.o.grepprg = string.format(
    "rg -F -S -H --no-heading --vimgrep %s '$*' \\| " .. sort_cmd,
    ignores
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
  api.nvim_create_user_command("Rg", rg, { bang = true, nargs = "+" })
end

api.nvim_create_user_command("Grep", grep, { bang = true, nargs = "+" })

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
