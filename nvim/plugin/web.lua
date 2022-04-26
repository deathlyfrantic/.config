local api = vim.api

local search_url = "https://duckduckgo.com/?q=%s"

local function browser(url)
  local open = "xdg-open"
  local args = {}
  if vim.fn.has("mac") == 1 then
    open = "open"
    table.insert(args, "-g")
  end
  table.insert(args, url)
  vim.loop.spawn(open, { args = args })
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

_G.web = { operator = operator }

-- Browse alias is for Fugitive's Gbrowse
api.nvim_create_user_command("Browse", "Web <args>", { nargs = 1 })
api.nvim_create_user_command("Web", function(args)
  browser(args.args)
end, { nargs = 1 })
api.nvim_create_user_command("Search", function(args)
  search(args.args)
end, { nargs = 1 })

vim.keymap.set(
  "n",
  "gw",
  ":set opfunc=v:lua.web.operator<CR>g@",
  { silent = true }
)
vim.keymap.set(
  "x",
  "gw",
  "<Cmd>call v:lua.web.operator(mode())<CR>",
  { silent = true }
)
