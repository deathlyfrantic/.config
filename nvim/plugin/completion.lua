local api = vim.api
local autocmd = require("autocmd")
local z = require("z")

local function findstart()
  local cursor = api.nvim_win_get_cursor(0)
  local pos = vim.fn.searchpos([[\s]], "bn")
  -- cursor is on same line as found whitespace
  if pos[1] == cursor[1] then
    return pos[2]
  end
  return 0
end

local function tab(fwd)
  local key_ctrln = api.nvim_replace_termcodes("<C-n>", true, false, true)
  local key_ctrlp = api.nvim_replace_termcodes("<C-p>", true, false, true)
  local key_tab = api.nvim_replace_termcodes("<Tab>", true, false, true)
  if vim.fn.pumvisible() > 0 then
    if fwd then
      return key_ctrln
    end
    return key_ctrlp
  elseif z.char_before_cursor():match("[A-Za-z0-9_]") then
    return key_ctrlp
  end
  return key_tab
end

local function undouble()
  -- stolen from Damian Conway
  -- https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/003fb8e06e1b8d321a129869a62eaa702cea6dc9/.vimrc#L1372-L1381
  local cursor = api.nvim_win_get_cursor(0)
  local line = api.nvim_get_current_line()
  local new_line = vim.fn.substitute(
    line,
    [[\(\.\?\k\+\)\%]] .. cursor[2] + 1 .. [[c\zs\1]],
    "",
    ""
  )
  api.nvim_buf_set_lines(0, cursor[1] - 1, cursor[1], true, { new_line })
end

local function wrap(f)
  if type(f) == "string" then
    -- assuming this is the name of a viml function
    f = vim.fn[f]
  end
  local cursor = api.nvim_win_get_cursor(0)
  local start = f(true, 0)
  local line = api.nvim_get_current_line()
  local base = line:sub(start, cursor[2] + 1)
  vim.fn.complete(start + 1, f(false, base))
end

local function gitcommit()
  wrap(function(fs, base)
    if fs then
      return findstart()
    end
    local cmd = "git log --oneline --no-merges"
    if #base > 0 then
      cmd = cmd .. " --grep='" .. base .. "'"
    else
      cmd = cmd .. " -n 5000"
    end
    local commits = io.popen(cmd):read("*all"):split("\n")
    table.sort(commits, function(a, b)
      -- chop off the commit hash when sorting
      return a:gsub("^%w+%s+", "") < b:gsub("^%w+%s", "")
    end)
    return vim.tbl_map(function(commit)
      return { abbr = commit, word = commit:split(" ")[1] }
    end, commits)
  end)
end

_G.completion = {
  findstart = findstart,
  gitcommit = gitcommit,
  tab = tab,
  wrap = wrap,
}

autocmd.add("CompleteDone", "*", undouble, { augroup = "completion-undouble" })

api.nvim_set_keymap(
  "i",
  "<Tab>",
  "v:lua.completion.tab(v:true)",
  { silent = true, expr = true }
)
api.nvim_set_keymap(
  "i",
  "<S-Tab>",
  "v:lua.completion.tab(v:false)",
  { silent = true, expr = true }
)
api.nvim_set_keymap(
  "i",
  "<C-x><C-g>",
  "<Cmd>call v:lua.completion.gitcommit()<CR>",
  { silent = true, noremap = true }
)
