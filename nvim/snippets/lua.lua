local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local c = ls.choice_node
local sn = ls.sn
local fmt = require("luasnip.extras.fmt").fmt

return {
  s("describe", fmt('describe("{}", function()\n  {}\nend)', { i(1), i(0) })),
  s("it", fmt('it("{}", function()\n  {}\nend)', { i(1), i(0) })),
  s("pending", fmt('pending("{}", function()\n  {}\nend)', { i(1), i(0) })),
  s("be", fmt("before_each(function()\n  {}\nend)", { i(0) })),
  s("ae", fmt("after_each(function()\n  {}\nend)", { i(0) })),
  s("lf", fmt("local function {}({})\n  {}\nend", { i(1), i(2), i(0) })),
  s(
    "req",
    fmt([[local {} = require("{}")]], {
      d(2, function(args)
        local text = args[1][1] or ""
        local pieces = text:split(".")
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
    })
  ),
}
