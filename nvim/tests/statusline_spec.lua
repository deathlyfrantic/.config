local stub = require("luassert.stub")
local statusline = require("z.statusline")

describe("statusline", function()
  describe("filename", function()
    after_each(function()
      vim.api.nvim_buf_set_name(0, "")
    end)

    it("returns filename with tilde", function()
      vim.api.nvim_buf_set_name(0, vim.fs.normalize("$HOME/foo/bar/baz.txt"))
      assert.equals(statusline.filename(), "~/foo/bar/baz.txt")
    end)

    it("returns cwd if buffer name is empty", function()
      assert.equals(
        statusline.filename(),
        "[cwd: " .. vim.loop.cwd():gsub(vim.fs.normalize("$HOME"), "~") .. "]"
      )
    end)
  end)

  describe("treesitter", function()
    local get_node

    before_each(function()
      get_node = stub(vim.treesitter, "get_node")
    end)

    after_each(function()
      get_node:revert()
    end)

    it("returns empty string if get_node() returns an error", function()
      get_node.invokes(function()
        error("error")
      end)
      assert.equals(statusline.treesitter(), "")
    end)

    it("returns empty string if get_node() returns a falsey value", function()
      get_node.returns(nil)
      assert.equals(statusline.treesitter(), "")
    end)

    it("returns node:type() if get_node() returns a node", function()
      get_node.returns({
        type = function()
          return "node type"
        end,
      })
      assert.equals(statusline.treesitter(), "node type")
    end)
  end)
end)
