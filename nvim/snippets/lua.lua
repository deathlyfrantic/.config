local ls = require("luasnip")
local i = ls.insert_node
local d = ls.dynamic_node
local c = ls.choice_node
local sn = ls.sn
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
local k = require("luasnip.nodes.key_indexer").new_key
local make = require("snippet-utils").make

local function fn_annotations(args)
  local pieces = vim.tbl_filter(function(piece)
    return not piece:is_empty()
  end, (args[1][1] or ""):split(","))
  local text = ""
  local insert_nodes = {}
  for idx, piece in ipairs(pieces) do
    text = text .. ("---@param %s {}\n"):format(piece:trim())
    table.insert(insert_nodes, i(idx, "nil"))
  end
  text = text .. "---@return {}\n"
  table.insert(insert_nodes, i(#insert_nodes + 1, "nil"))
  return sn(nil, fmt(text, insert_nodes))
end

return make({
  describe = fmt(
    [[
      describe("{}", function()
        {}
      end)
    ]],
    { i(1), i(0) }
  ),
  it = fmt(
    [[
      it("{}", function()
        {}
      end)
    ]],
    { i(1), i(0) }
  ),
  pending = fmt(
    [[
      pending("{}", function()
        {}
      end)
    ]],
    { i(1), i(0) }
  ),
  be = [[
    before_each(function()
      {}
    end)]],
  ae = [[
    after_each(function()
      {}
    end)]],
  lf = fmt(
    [[
      {annotations}
      local function {name}({args})
        {body}
      end
    ]],
    {
      annotations = d(3, fn_annotations, { 2 }),
      name = i(1),
      args = i(2),
      body = i(0),
    }
  ),
  mf = fmt(
    [[
      {annotations}
      function M.{name}({args})
        {body}
      end
    ]],
    {
      annotations = d(3, fn_annotations, { 2 }),
      name = i(1),
      args = i(2),
      body = i(0),
    }
  ),
  module = fmt(
    [[
      local M = {}

      <annotations>
      function M.<name>(<args>)
        <body>
      end

      return M
    ]],
    {
      annotations = d(3, fn_annotations, { 2 }),
      name = i(1),
      args = i(2),
      body = i(0),
    },
    { delimiters = "<>" }
  ),
  class = fmt(
    [[
      ---@class <class>
      local <name> = {}
      <class>.__index = <class>

      function <class>.new(...)
        <body>
        return setmetatable(..., <class>)
      end

      ---@overload fun(...): <class>
      return setmetatable({}, {
        __call = function(_, ...)
          return <class>.new(...)
        end,
        __index = <class>
      })
    ]],
    {
      class = rep(k("insert_name")),
      name = i(1, "", { key = "insert_name" }),
      body = i(0),
    },
    { delimiters = "<>", repeat_duplicates = true }
  ),
  req = fmt([[local {} = require("{}")]], {
    d(2, function(args)
      local pieces = (args[1][1] or ""):split(".")
      local options = {}
      for len = 0, #pieces - 1 do
        local option = table
          .concat(vim.list_slice(pieces, #pieces - len, #pieces), "_")
          :gsub("-", "_")
        table.insert(options, i(nil, option))
      end
      if #options == 0 then
        options = { i(nil, "") }
      end
      return sn(nil, {
        c(1, options),
      })
    end, { 1 }),
    i(1),
  }),
})
