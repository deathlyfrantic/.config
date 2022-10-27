local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s(
    "ifmain",
    fmt(
      [[
  function main() {
    <>
  }

  if (require.main === module) {
    main();
  }
  ]],
      { i(0) },
      { delimiters = "<>" }
    )
  ),
  s(
    "describe",
    fmt(
      [[
  describe("[]", () => {
    []
  };
  ]],
      { i(1), i(0) },
      { delimiters = "[]" }
    )
  ),
  s(
    "it",
    fmt(
      [[
  it("[]", async () => {
    []
  };
  ]],
      { i(1), i(0) },
      { delimiters = "[]" }
    )
  ),
}
