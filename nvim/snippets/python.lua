local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s(
    "ifmain",
    fmt(
      [[
  def main():
      {}

  if __name__ == "__main__":
      main()
  ]],
      { i(0) }
    )
  ),
  s(
    "logfn",
    t({
      "from pprint import pprint",
      "def log(s):",
      "    with open('log.txt', 'a') as f:",
      "        pprint(s, stream=f)",
      "",
      "",
      "",
    })
  ),
}
