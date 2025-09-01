local ls = require("luasnip")
local fmta = require("luasnip.extras.fmt").fmta
local c = ls.choice_node
local d = ls.dynamic_node
local i = ls.insert_node
local t = ls.text_node
local sn = ls.snippet_node
local make = require("snippet-utils").make
local coerce = require("coerce")

-- return snippet largely stolen from TJ Devries. references:
-- https://github.com/tjdevries/config_manager/blob/afbb6942b712174a7e87acbca6908e283caa46cc/xdg_config/nvim/lua/tj/snips/ft/go.lua
-- https://github.com/tjdevries/config_manager/blob/afbb6942b712174a7e87acbca6908e283caa46cc/xdg_config/nvim/queries/go/return-snippet.scm

local default_values = {
  bool = "false",
  error = "err",
  float32 = "0",
  float64 = "0",
  int = "0",
  string = '""',
}

---Transforms some text into a snippet node
---@param text string
local transform = function(text)
  local ret = text
  if default_values[text] then
    ret = default_values[text]
  elseif text:starts_with("*") then
    -- starts with * so it's a pointer, return nil
    ret = "nil"
  elseif text:match("^%u") then
    -- no *, starts with capital letter, assume it's a struct
    ret = (text .. "{}")
  end
  return t(ret)
end

-- Maps a node type to a handler function.
local handlers = {
  parameter_list = function(node)
    local ret = {}
    local count = node:named_child_count()
    for idx = 0, count - 1 do
      local type_node = node:named_child(idx):field("type")[1]
      table.insert(ret, transform(vim.treesitter.get_node_text(type_node, 0)))
      if idx ~= count - 1 then
        table.insert(ret, t({ ", " }))
      end
    end
    return ret
  end,
  type_identifier = function(node)
    return { transform(vim.treesitter.get_node_text(node, 0)) }
  end,
}

local function_node_types = {
  function_declaration = true,
  method_declaration = true,
  func_literal = true,
}

--- Gets the corresponding result type based on the
--- current function context of the cursor.
local function go_result_type()
  -- find the first function node that's a parent of the cursor
  local node = vim.treesitter.get_node()
  while node and not function_node_types[node:type()] do
    node = node:parent()
  end
  -- exit if no match
  if not node then
    vim.notify("Not inside of a function", vim.log.levels.ERROR)
    return t("")
  end
  local query = vim.treesitter.query.parse(
    "go",
    [[ [(method_declaration result: (_) @type)
       (function_declaration result: (_) @type)
       (func_literal result: (_) @type)] ]]
  )
  for _, capture in query:iter_captures(node, 0) do
    if handlers[capture:type()] then
      return handlers[capture:type()](capture)
    end
  end
end

return make({
  ife = fmta(
    ([[
      if err != nil {
      	return <result>
      }
      <finish>]]):dedent(),
    {
      result = d(1, function()
        return sn(nil, go_result_type())
      end, {}),
      finish = i(0),
    }
  ),
  s = fmta(
    [[
      type <name> struct {
      	<member> <type> <finish>
      }]],
    {
      name = i(1),
      member = i(2),
      type = c(
        3,
        vim.tbl_map(function(v)
          return i(nil, v)
        end, vim.tbl_keys(default_values))
      ),
      finish = i(0),
    }
  ),
  st = fmta([[`<type>:"<tag>"`]], {
    type = c(1, { i(nil, "json"), i(nil, "yaml") }),
    tag = d(2, function()
      ---@type string?
      local name =
        vim.api.nvim_get_current_line():trim():split("%s", { plain = false })[1]
      if (name or ""):starts_with("`json:") then
        name = nil
      end
      local choices = { i(nil, name) } -- works even if `name` is nil
      if name then
        table.insert(choices, i(nil, coerce.mixed_case(name)))
        table.insert(choices, i(nil, coerce.snake_case(name)))
        table.insert(choices, i(nil, coerce.camel_case(name)))
      end
      table.insert(choices, i(nil, "-"))
      return sn(nil, {
        c(1, choices),
      })
    end, {}),
  }),
})
