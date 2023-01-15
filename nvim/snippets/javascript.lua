local ls = require("luasnip")
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local make = require("z.snippets").make

return make({
  ifmain = fmt(
    [[
      function main() {
        <>
      }

      if (<>) {
        main();
      }
    ]],
    { i(0), c(1, { t("import.meta.main"), t("require.main === module") }) },
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
