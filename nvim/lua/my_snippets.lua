local utils = require("snippets.utils")
local dedent = require("plenary.strings").dedent
local match_indentation = utils.match_indentation
local force_comment = utils.force_comment

local function mid(s)
  return match_indentation(dedent(s))
end

local all = {
  date = function()
    return os.date("%F")
  end,
  time = function()
    return os.date("%H:%M")
  end,
  lorem = mid([[
      Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod
      tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At
      vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren,
      no sea takimata sanctus est Lorem ipsum dolor sit amet.]]),
  todo = force_comment([[TODO(${1=os.getenv("USER")} - ${=os.date("%F")}): $0]]),
  modeline = force_comment(function()
    local pieces = { "vim:set" }
    if #vim.bo.filetype > 0 then
      table.insert(pieces, "ft=" .. vim.o.filetype)
    end
    if vim.bo.expandtab then
      table.insert(
        pieces,
        string.format("et sw=%s ts=%s", vim.bo.shiftwidth, vim.bo.tabstop)
      )
    else
      table.insert(
        pieces,
        string.format(
          "noet sts=%s sw=%s ts=%i",
          vim.bo.softtabstop,
          vim.bo.shiftwidth,
          vim.bo.tabstop
        )
      )
    end
    if vim.bo.textwidth > 0 then
      table.insert(pieces, "tw=" .. vim.bo.textwidth)
    end
    if vim.wo.foldmethod == "marker" then
      table.insert(pieces, "fdm=marker")
    end
    return table.concat(pieces, " ")
  end),
}

local rust = {
  tests = dedent([[
      #[cfg(test)]
      mod tests {
          use super::*;

          #[test]
          fn test_$1() {
              $0
          }
      }]]),
  test = mid([[
      #[test]
      fn test_$1() {
          $0
      }]]),
  der = "#[derive($0)]",
  dd = "#[derive(Debug)]\n$0",
  display = mid([[
      impl fmt::Display for $1 {
          fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
              write!(f, "${2:{}}", $0)
          }
      }]]),
  default = mid([[
      impl Default for $1 {
          fn default() -> Self {
              ${2:$1} {
                  $0
              }
          }
      }]]),
}

local vim = {
  aug = mid([[
      augroup $1
        autocmd!
        $0
      augroup END]]),
}

local javascript = {
  ifmain = mid([[
    function main() {
      $0
    }

    if (require.main === module) {
      main();
    }]]),
  describe = mid([[
    describe("$1", () => {
      $0
    });]]),
  it = mid([[
    it("$1", async () => {
      $0
    });]]),
}

local python = {
  ifmain = mid([[
      def main():
          $0

      if __name__ == "__main__":
          main()]]),
  logfn = mid([[
      from pprint import pprint
      def log(s):
          with open('log.txt', 'a') as f:
              pprint(s, stream=f)
      $0]]),
}

local c = {
  main = dedent([[
    int main(int argc, char *argv[]) {
        $0
        return EXIT_SUCCESS;
    }]]),
  vmain = dedent([[
    void main(int argc, char *argv[]) {
        $0
    }]]),
  ["for"] = mid([[
      for (size_t i = 0; i < $1; i++) {
          $0
      }]]),
}

return {
  _global = all,
  c = c,
  javascript = javascript,
  python = python,
  rust = rust,
  typescript = javascript,
  vim = vim,
}
