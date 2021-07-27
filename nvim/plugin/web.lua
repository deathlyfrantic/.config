local search_url = "https://duckduckgo.com/?q=%s"

local function browser(url)
  local open = "xdg-open"
  if vim.fn.has("mac") == 1 then
    open = "open -g"
  end
  os.execute(open .. " " .. vim.fn.shellescape(url, true))
end

local function search(url)
  if not vim.startswith(url, "http") then
    url = search_url:format(url:gsub(" ", "+"))
  end
  browser(url)
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
  local url = vim.fn.getreg("@"):trim()
  vim.o.selection = selsave
  vim.fn.setreg("@", regsave)
  if url:match("\n") then
    error()
    return
  elseif url == "" then
    error("No selection")
    return
  end
  search(url)
end

_G.web = { operator = operator, browser = browser, search = search }

-- Browse alias is for Fugitive's Gbrowse
vim.cmd("command! -nargs=1 Browse Web <args>")
vim.cmd("command! -nargs=1 Web call v:lua.web.browser(<f-args>)")
vim.cmd("command! -nargs=1 Search call v:lua.web.search(<f-args>)")

vim.api.nvim_set_keymap(
  "n",
  "gw",
  ":set opfunc=v:lua.web.operator<CR>g@",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "x",
  "gw",
  "<Cmd>call v:lua.web.operator(mode())<CR>",
  { noremap = true, silent = true }
)
