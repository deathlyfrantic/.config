local ls = require("luasnip")
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local make = require("z.snippets").make

return make({
  ifmain = [[
    def main():
        {}

    if __name__ == "__main__":
        main()
  ]],
  logfn = [[
    from pprint import pprint
    def log(s):
        with open('log.txt', 'a') as f:
            pprint(s, stream=f)


    ]],
  init = fmt(
    [[
      def __init__(self, {}):
          {}
          {}
    ]],
    {
      i(1),
      f(function(args)
        local pieces =
          vim.split(args[1][1] or "", ",", { plain = true, trimempty = true })
        if #pieces == 0 then
          return ""
        end
        local words = {}
        for _, piece in ipairs(pieces) do
          local word = piece:trim():match("^[%a_][%w_]*")
          if word then
            table.insert(words, word)
          end
        end
        local ret = {}
        for n, word in ipairs(words) do
          local indent = ""
          if n > 1 then
            indent = "    "
          end
          table.insert(ret, indent .. "self." .. word .. " = " .. word)
        end
        return ret
      end, { 1 }),
      i(0),
    }
  ),
})
