local ls = require("luasnip")
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local c = ls.choice_node
local sn = ls.sn
local fmt = require("luasnip.extras.fmt").fmt
local make = require("z.snippets").make

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
      local function {}({})
        {}
      end
    ]],
    { i(1), i(2), i(0) }
  ),
  req = fmt([[local {} = require("{}")]], {
    d(2, function(args)
      local pieces = (args[1][1] or ""):split(".", { plain = true })
      local options = {}
      for len = 0, #pieces - 1 do
        local option = table
          .concat(vim.list_slice(pieces, #pieces - len, #pieces), "_")
          :gsub("-", "_")
        table.insert(options, t(option))
      end
      return sn(nil, {
        c(1, options),
      })
    end, { 1 }),
    i(1),
  }),
})
