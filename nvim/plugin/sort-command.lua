local utils = require("utils")

-- determine the separator, as defined by whichever punctuation character occurs
-- most frequently within the string. if there are no punctuation characters but
-- there is whitespace, then the separator is a single space.
---@param text string
---@return string
local function determine_separator(text)
  local counts = {}
  local has_whitespace = false
  for _, char in text:chars() do
    local match = char:match("%p")
    if match then
      if not counts[match] then
        counts[match] = 0
      end
      counts[match] = counts[match] + 1
    elseif not has_whitespace and char:match("%s") then
      has_whitespace = true
    end
  end
  -- if there are no punctuation characters, return a single space
  if vim.tbl_count(counts) == 0 then
    return " "
  end
  -- return the most frequently occurring punctuation character
  local max = { count = 0 }
  for key, count in pairs(counts) do
    if count > max.count then
      max.key = key
      max.count = count
    end
  end
  return max.key
end

-- determine if the glue needs a trailing space, so that
-- "c,b,a" becomes "a,b,c"
-- "c, b, a" becomes "a, b, c"
---@param pieces string[]
---@param separator string
---@return string
local function determine_glue(pieces, separator)
  local contains_space = utils.tbl_any(function(piece)
    return piece:find("^%s") or piece:find("%s$")
  end, pieces)
  return separator .. (contains_space and " " or "")
end

-- descending (normal) sort -> a, b, c
---@generic T
---@param a T
---@param b T
---@return boolean
local function descending_sort(a, b)
  return a > b
end

-- ascending (reverse) sort -> c, b, a
---@generic T
---@param a T
---@param b T
---@return boolean
local function ascending_sort(a, b)
  return a < b
end

---@param text string
---@param separator? string
---@param cmp? fun(a: any, b: any): boolean
local function get_replacement_text(text, separator, cmp)
  separator = separator or determine_separator(text)
  cmp = cmp or ascending_sort
  local pieces = text:split(separator, { plain = true })
  -- need to determine glue before trimming all the pieces
  local glue = determine_glue(pieces, separator)
  pieces = vim.tbl_map(function(piece)
    return piece:trim()
  end, pieces)
  table.sort(pieces, cmp)
  return table.concat(pieces, glue)
end

---@param args { args: string, bang: boolean }
local function sort_command(args)
  local start = vim.api.nvim_buf_get_mark(0, "<")
  local stop = vim.api.nvim_buf_get_mark(0, ">")
  if start[1] ~= stop[1] then
    vim.notify(
      "This command does not work on multiline selections.",
      vim.log.levels.ERROR
    )
    return
  end
  -- buf_get_mark() rows are 1-indexed, but nvim_buf_get_text() is 0-indexed, so
  -- need to subtract one from row. end col doesn't include character the cursor
  -- is on, so add one.
  local row, start_col, stop_col = start[1] - 1, start[2], stop[2] + 1
  -- if mode was visual-line, end col will be some enormous number, so clamp it
  local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
  if #line < stop_col then
    stop_col = #line
  end
  local text = vim.api.nvim_buf_get_text(0, row, start_col, row, stop_col, {})
  local separator = args.args ~= "" and args.args
    or determine_separator(text[1])
  local replacement = get_replacement_text(
    text[1],
    separator,
    args.bang and descending_sort or ascending_sort
  )
  vim.api.nvim_buf_set_text(0, row, start_col, row, stop_col, { replacement })
end

vim.api.nvim_create_user_command(
  "Sort",
  sort_command,
  { nargs = "?", range = true, bang = true }
)

_G.sort = {
  operator = utils.make_operator_fn(function(text)
    local start = vim.api.nvim_buf_get_mark(0, "[")
    local stop = vim.api.nvim_buf_get_mark(0, "]")
    local row, start_col, stop_col = start[1] - 1, start[2], stop[2] + 1
    local replacement = get_replacement_text(text)
    vim.api.nvim_buf_set_text(0, row, start_col, row, stop_col, { replacement })
  end),
}

vim.keymap.set(
  "n",
  "gS",
  ":set opfunc=v:lua.sort.operator<CR>g@",
  { silent = true }
)
vim.keymap.set("x", "gS", ":Sort<CR>", { silent = true })
