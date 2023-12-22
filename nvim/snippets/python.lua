local ls = require("luasnip")
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local make = require("snippet-utils").make

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
      def __init__(self, {args}):
          {set_vars}
          {body}
    ]],
    {
      args = i(1),
      set_vars = f(function(args)
        local pieces = (args[1][1] or ""):split(
          ",",
          { plain = true, trimempty = true }
        )
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
          local indent = n > 1 and "    " or ""
          table.insert(ret, indent .. "self." .. word .. " = " .. word)
        end
        return ret
      end, { 1 }),
      body = i(0),
    }
  ),
})
