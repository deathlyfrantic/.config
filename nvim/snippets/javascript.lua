local ls = require("luasnip")
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local make = require("z.snippets").make

return make({
  ifmain = fmt(
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
  ),
  describe = fmt(
    [[
      describe("[]", () => {
        []
      };
    ]],
    { i(1), i(0) },
    { delimiters = "[]" }
  ),
  it = fmt(
    [[
      it("[]", async () => {
        []
      };
    ]],
    { i(1), i(0) },
    { delimiters = "[]" }
  ),
})
