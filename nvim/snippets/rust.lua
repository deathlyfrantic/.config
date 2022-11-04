local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  s(
    "tests",
    fmt(
      [[
  #[cfg(test)]
  mod tests {
      use super::*;

      #[test]
      fn test_<>() {
          <>
      }
  }
  ]],
      { i(1), i(0) },
      { delimiters = "<>" }
    )
  ),
  s(
    "test",
    fmt(
      [[
  #[test]
  fn test_<>() {
      <>
  }
  ]],
      { i(1), i(0) },
      { delimiters = "<>" }
    )
  ),
  s("der", fmt("#[derive({})]\n{}", { i(1), i(0) })),
  s("dd", fmt("#[derive(Debug)]\n{}", { i(0) })),
  s(
    "display",
    fmt(
      [[
  impl fmt::Display for [] {
      fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
          write!(f, "[]", [])
      }
  }
  ]],
      { i(1), c(1, { i(2, "{}"), i(2, "{:?}") }), i(0) },
      { delimiters = "[]" }
    )
  ),
  s(
    "default",
    fmt(
      [[
  impl Default for [] {
      fn default() -> Self {
          [] {
            []
          }
      }
  }
  ]],
      { i(1), rep(1), i(0) },
      { delimiters = "[]" }
    )
  ),
}