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
})
