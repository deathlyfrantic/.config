local utils = require("utils")

local M = {}

-- web search URL; `%s` is replaced with the search term
M.search_url = "https://duckduckgo.com/?q=%s"

-- URL encode a string
---@param url string
---@return string
function M.url_encode(url)
  local ret, _ = vim
    .iconv(url, "latin1", "utf-8")
    :gsub("[^%w_.~-]", function(char)
      return ("%%%02X"):format(char:byte())
    end)
  return ret
end

-- Open a URL in the system browser.
---@param url string
function M.browser(url)
  vim.ui.open(url, { cmd = { "open", "-g" } })
end

-- Search for a string in the default search engine.
---@see M.search
---@param url string
function M.search(url)
  if not url:starts_with("http") then
    url = M.search_url:format(M.url_encode(url:trim()))
  end
  M.browser(url)
end

M.operator = utils.make_operator_fn(function(url)
  M.search(url:trim())
end)

function M.init()
  -- Browse alias is for Fugitive's Gbrowse
  vim.api.nvim_create_user_command("Browse", "Web <args>", { nargs = 1 })
  vim.api.nvim_create_user_command("Web", function(args)
    M.browser(args.args)
  end, { nargs = 1 })
  vim.api.nvim_create_user_command("Search", function(args)
    M.search(args.args)
  end, { nargs = 1 })
  vim.keymap.set("n", "gw", function()
    vim.o.opfunc = "v:lua.require'web'.operator"
    return "g@"
  end, { expr = true, silent = true })
  vim.keymap.set(
    "x",
    "gw",
    -- below line is required because of mode-switching behavior of operators,
    -- can't use a regular lua function
    "<Cmd>call v:lua.require'web'.operator(mode())<CR>",
    { silent = true }
  )
end

return M
