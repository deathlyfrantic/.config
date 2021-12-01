local function grep(search)
  vim.cmd(
    "silent grep! " .. search:gsub("#", [[\#]]):gsub(vim.pesc("%"), [[\%]])
  )
  local num_results = #vim.fn.getqflist()
  if num_results == 0 then
    vim.cmd("redraw!")
    vim.api.nvim_echo({ { "No matches found." } }, false, {})
  else
    vim.cmd("botright copen " .. math.min(num_results, 10))
    vim.w.quickfix_title = string.format([[grep "%s"]], search)
  end
end

local function operator(kind)
  local error = function(msg)
    vim.api.nvim_err_writeln(
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
  grep(search)
end

_G.grep = { operator = operator, grep = grep }

if vim.fn.executable("rg") then
  local ignores = table.concat(
    vim.tbl_map(function(v)
      return string.format("-g '!%s'", v)
    end, vim.split(vim.o.wildignore, ",")),
    " "
  )
  vim.o.grepprg = string.format(
    "rg -F -S -H --no-heading --vimgrep %s '$*'",
    ignores
  )
  vim.o.grepformat = "%f:%l:%c:%m"

  -- :Rg command variant allows passing arbitrary flags to ripgrep and doesn't
  -- default to -F (fixed-strings) option to allow regex searching
  _G.grep.rg = function(search)
    local saved_grepprg = vim.opt_local.grepprg:get()
    vim.opt_local.grepprg = "rg -H --no-heading --vimgrep $*"
    grep(search)
    vim.opt_local.grepprg = saved_grepprg
  end
  vim.cmd("command! -nargs=+ Rg call v:lua.grep.rg(<q-args>)")
end

vim.cmd("command! -nargs=+ Grep call v:lua.grep.grep(<q-args>)")

vim.api.nvim_set_keymap("n", "g/", ":Grep ", { noremap = true })
vim.api.nvim_set_keymap(
  "n",
  "g/%",
  ":Grep <C-r>=expand('%:p:t:r')<CR><CR>",
  { noremap = true }
)
vim.api.nvim_set_keymap(
  "n",
  "gs",
  ":set opfunc=v:lua.grep.operator<CR>g@",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "x",
  "gs",
  "<Cmd>call v:lua.grep.operator(mode())<CR>",
  { noremap = true, silent = true }
)
