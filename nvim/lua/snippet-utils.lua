local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local partial = require("luasnip.extras").partial
local fmt = require("luasnip.extras.fmt").fmt
local utils = require("utils")

local M = {}

---@return string, string?
function M.comment_string()
  if
    utils.highlight_at_pos_contains("comment") or vim.o.commentstring:is_empty()
  then
    return ""
  end
  local before, after = unpack(vim.o.commentstring:split("%s"))
  if not before:ends_with(" ") then
    before = before .. " "
  end
  if after and not after:starts_with(" ") then
    after = " " .. after
  end
  return before, after
end

-- Force a snippet to be a comment. If it is already a comment, basically a
-- no-op; if it is not, add vim.o.commentstring to the front (and back if
-- applicable) of the snippet text.
---@param text string
---@param nodes table[]
---@return table
function M.force_comment(text, nodes)
  -- these need to be partials so that `comment_string` is evaluated at the time
  -- the snippet is expanded, rather than when this function is called
  local function get_part(part)
    return select(part, M.comment_string()) or ""
  end
  table.insert(nodes, 1, partial(get_part, 1))
  table.insert(nodes, partial(get_part, 2))
  return fmt("{}" .. text .. "{}", nodes)
end

---@param snippet string
---@return table
local function text_snippet(snippet)
  if snippet:find("{}") then
    return fmt(snippet, { i(0) })
  end
  if snippet:find("\n") then
    return t(snippet:dedent():splitlines())
  end
  return t(snippet)
end

---@param snippet string | table
---@return table
local function nodes(snippet)
  if type(snippet) == "string" then
    return text_snippet(snippet)
  end
  if type(snippet) == "table" and not getmetatable(snippet) then
    return vim.tbl_map(function(snip)
      return type(snip) == "string" and text_snippet(snip) or snip
    end, snippet)
  end
  return snippet
end

-- Convenience method to create snippets out of a table by using the keys as the
-- names of the snippets.
---@param snippets table
---@return table
function M.make(snippets)
  local ret = {}
  for k, v in pairs(snippets) do
    table.insert(ret, s(k, nodes(v)))
  end
  return ret
end

return M
