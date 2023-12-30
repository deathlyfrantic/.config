local ls = require("luasnip")
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local partial = require("luasnip.extras").partial
local force_comment = require("snippet-utils").force_comment
local make = require("snippet-utils").make

return make({
  date = partial(os.date, "%F"),
  time = partial(os.date, "%H%:%M"),
  lorem = [[
    Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod
    tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At
    vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren,
    no sea takimata sanctus est Lorem ipsum dolor sit amet.

    ]],
  todo = force_comment("TODO{}: {}", {
    c(1, {
      -- needs to be a dynamic node so `os.date()` call gets evaluated when
      -- snippet is expanded
      d(1, function()
        return sn(
          nil,
          fmt("({} - {})", {
            i(1, os.getenv("USER")),
            i(2, os.date("%F")),
          })
        )
      end, {}),
      t(""),
    }),
    i(0),
  }),
})
