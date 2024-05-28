local utils = require("utils")

local search_url = "https://duckduckgo.com/?q=%s"

---@param url string
local function browser(url)
  vim.system({ "open", "-g", url })
end

---@param url string
local function search(url)
  if not url:starts_with("http") then
    url = search_url:format(url:gsub(" ", "+"))
  end
  browser(url)
end

_G.web = {
  operator = utils.make_operator_fn(function(url)
    search(url:trim())
  end),
}

-- Browse alias is for Fugitive's Gbrowse
vim.api.nvim_create_user_command("Browse", "Web <args>", { nargs = 1 })
vim.api.nvim_create_user_command("Web", function(args)
  browser(args.args)
end, { nargs = 1 })
vim.api.nvim_create_user_command("Search", function(args)
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
