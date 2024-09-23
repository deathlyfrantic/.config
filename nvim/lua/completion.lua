local utils = require("utils")
local luasnip = require("luasnip")

local M = {}

---@return integer
local function find_start()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local pos = vim.fn.searchpos([[\s]], "bn")
  -- cursor is on same line as found whitespace
  return pos[1] == row and pos[2] or 0
end

---@param start integer
---@return string
local function find_base(start)
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local base = vim.api.nvim_get_current_line():sub(start + 1, col + 1)
  return base:is_empty() and "" or base
end

---@param fwd boolean
---@return string
local function tab(fwd)
  if vim.fn.pumvisible() > 0 then
    return fwd and "<C-n>" or "<C-p>"
  elseif utils.char_before_cursor():match("[A-Za-z0-9_]") then
    return "<C-p>"
  end
  return "<Tab>"
end

-- if completing in the middle of a word, remove the completed portion already
-- on the line, i.e. completing "foobar" with cursor position foo|bar results in
-- "foobar" instead of "foobarbar".
-- stolen from Damian Conway
-- https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/003fb8e06e1b8d321a129869a62eaa702cea6dc9/.vimrc#L1372-L1381
local function undouble()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local new_line =
    vim.fn.substitute(line, [[\(\.\?\k\+\)\%]] .. col + 1 .. [[c\zs\1]], "", "")
  vim.api.nvim_buf_set_lines(0, row - 1, row, true, { new_line })
end

---@param fs integer
---@param base string
---@return integer | table
function M.snippets(fs, base)
  if fs == 1 then
    return find_start()
  end
  local snippets = {}
  for filetype, ft_snippets in pairs(luasnip.available()) do
    for _, snippet in ipairs(ft_snippets) do
      if snippet.trigger:match(base) then
        table.insert(snippets, {
          word = snippet.trigger,
          abbr = snippet.description[1],
          menu = ("[%s]"):format(filetype),
          kind = "S",
        })
      end
    end
  end
  return snippets
end

local function gitcommit()
  local start = find_start()
  local base = find_base(start)
  local cmd = { "git", "log", "--oneline", "--no-merges" }
  vim.list_extend(cmd, #base > 0 and { "--grep", base } or { "-n", "5000" })
  local commits = vim.system(cmd, { text = true }):wait().stdout:split("\n")
  table.sort(commits, function(a, b)
    -- chop off the commit hash when sorting
    return a:gsub("^%w+%s+", "") < b:gsub("^%w+%s", "")
  end)
  local candidates = vim.tbl_map(function(commit)
    return {
      abbr = commit,
      word = commit:split(" ")[1],
    }
  end, commits)
  vim.fn.complete(start + 1, candidates)
end

---@param command string[]
---@param error_message string
---@return string
local function get_tmux_output(command, error_message)
  table.insert(command, 1, "tmux")
  local result = vim.system(command, { text = true }):wait()
  if result.code ~= 0 then
    error(error_message)
  end
  return result.stdout:trim()
end

local function tmux()
  local start = find_start()
  local base = find_base(start)
  local uniques = {}
  local words = {}
  -- get current pane data so we can filter it out later
  local current_pane = get_tmux_output(
    { "display-message", "-p", "11-#{session_id}" },
    "Failed to retrieve current tmux pane id."
  )
  -- find all the panes
  vim
    .iter(get_tmux_output({
      "list-panes",
      "-a",
      "-F",
      "#{pane_active}#{window_active}-#{session_id} #{pane_id}",
    }, "Failed to retrive list of tmux panes."):split("\n"))
    :filter(function(pane)
      -- filter out current pane - we can use tmux-thumbs for it
      return not pane:starts_with(current_pane)
    end)
    :map(function(pane)
      -- strip out active/session data, leave just pane id
      return pane:split(" ")[2]
    end)
    :map(function(pane)
      -- get the contents from the pane
      return get_tmux_output(
        { "capture-pane", "-J", "-p", "-t", pane },
        ("Failed to capture tmux pane '%s'."):format(pane)
      )
    end)
    :map(function(contents)
      -- split the contents of the pane on whitespace
      vim
        .iter(contents:split("%s", { plain = false }))
        :filter(function(s)
          -- filter out "words" that don't contain an alphanumeric character
          return s:match("%w")
        end)
        :each(function(word)
          -- ensure each "word" is only added to the list once
          if not uniques[word] then
            table.insert(words, word)
            uniques[word] = word
          end
        end)
    end)
  -- sort the words
  table.sort(words)
  -- find a word that starts with the base
  local candidates = vim.tbl_filter(function(word)
    return word:imatch("^" .. base)
  end, words)
  -- if there are no words, find words that contain the base anywhere
  if #candidates == 0 then
    candidates = vim.tbl_filter(function(word)
      return word:imatch(base)
    end, words)
  end
  vim.fn.complete(start + 1, candidates)
end

function M.init()
  vim.api.nvim_create_autocmd("CompleteDone", {
    pattern = "*",
    callback = undouble,
    group = vim.api.nvim_create_augroup("completion-undouble", {}),
  })
  vim.keymap.set("i", "<Tab>", function()
    return tab(true)
  end, { silent = true, expr = true })
  vim.keymap.set("i", "<S-Tab>", function()
    return tab(false)
  end, { silent = true, expr = true })
  vim.keymap.set("i", "<C-x><C-g>", gitcommit, { silent = true })
  vim.keymap.set("i", "<C-x><C-t>", tmux, { silent = true })
  vim.o.completefunc = "v:lua.require'completion'.snippets"
end

return M
