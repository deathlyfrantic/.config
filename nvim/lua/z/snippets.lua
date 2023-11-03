local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local partial = require("luasnip.extras").partial
local fmt = require("luasnip.extras.fmt").fmt
local dedent = require("plenary.strings").dedent
local z = require("z")

local M = {}

function M.comment_string()
  if z.highlight_at_pos_contains("comment") then
    return ""
  end
  local before, after =
    unpack(vim.o.commentstring:split("%s", { plain = true, trimempty = true }))
  if not before:ends_with(" ") then
    before = before .. " "
  end
  if after and not after:starts_with(" ") then
    after = " " .. after
  end
  return before, after
end

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

local function text_snippet(snippet)
  if snippet:find("{}") then
    return fmt(snippet, { i(0) })
  end
  if snippet:find("\n") then
    return t(dedent(snippet):split("\n", { plain = true, trimempty = true }))
  end
  return t(snippet)
end

local function nodes(snippet)
  if type(snippet) == "string" then
    return text_snippet(snippet)
  end
  if type(snippet) == "table" and not getmetatable(snippet) then
    local ret = {}
    for k, v in ipairs(snippet) do
      if type(v) == "string" then
        ret[k] = text_snippet(v)
      else
        ret[k] = v
      end
    end
    return ret
  end
  return snippet
end

function M.make(snippets)
  local ret = {}
  for k, v in pairs(snippets) do
    table.insert(ret, s(k, nodes(v)))
  end
  return ret
end

return M
