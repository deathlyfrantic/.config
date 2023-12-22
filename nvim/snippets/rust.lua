local ls = require("luasnip")
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
local k = require("luasnip.nodes.key_indexer").new_key
local make = require("snippet-utils").make

return make({
  tests = fmt(
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
  ),
  test = fmt(
    [[
      #[test]
      fn test_<>() {
          <>
      }
    ]],
    { i(1), i(0) },
    { delimiters = "<>" }
  ),
  der = fmt("#[derive({})]\n{}", { i(1), i(0) }),
  dd = "#[derive(Debug)]\n{}",
  display = fmt(
    [[
      impl fmt::Display for [struct] {
          fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
              write!(f, "[pattern]", [output])
          }
      }
    ]],
    {
      struct = i(1),
      pattern = c(2, { i(2, "{}"), i(2, "{:?}") }),
      output = i(0),
    },
    { delimiters = "[]" }
  ),
  default = fmt(
    [[
      impl Default for [struct] {
          fn default() -> Self {
              [struct_name] {
                  [body]
              }
          }
      }
    ]],
    {
      struct = i(1, "", { key = "struct" }),
      struct_name = rep(k("struct")),
      body = i(0),
    },
    { delimiters = "[]" }
  ),
})
