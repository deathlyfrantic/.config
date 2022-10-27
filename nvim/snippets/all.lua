local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local partial = require("luasnip.extras").partial

return {
  s("date", partial(os.date, "%F")),
  s("time", partial(os.date, "%H%:%M")),
  s(
    "lorem",
    fmt(
      [[
      Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod
      tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At
      vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren,
      no sea takimata sanctus est Lorem ipsum dolor sit amet.

      ]],
      {}
    )
  ),
  s(
    "todo",
    fmt("TODO{}: {}", {
      c(1, {
        fmt("({} - {})", {
          i(1, os.getenv("USER")),
          i(2, os.date("%F")),
        }),
        t(""),
      }),
      i(0),
    })
  ),
}
