local stub = require("luassert.stub")
local snippets = require("snippet-utils")
local utils = require("utils")

describe("snippets", function()
  describe("comment_string", function()
    local highlight_at_pos_contains
    local cms = vim.o.cms

    before_each(function()
      highlight_at_pos_contains = stub(utils, "highlight_at_pos_contains")
    end)

    after_each(function()
      highlight_at_pos_contains:revert()
      vim.o.cms = cms
    end)

    it("returns empty string if already in a comment", function()
      highlight_at_pos_contains:returns(true)
      local before, after = snippets.comment_string()
      assert.equals("", before)
      assert.is_nil(after)
    end)

    it("doesn't error if commentstring is ''", function()
      vim.o.cms = ""
      local before, after = snippets.comment_string()
      assert.equals("", before)
      assert.is_nil(after)
    end)

    it("returns before but not after for line comments", function()
      vim.o.cms = "-- %s"
      highlight_at_pos_contains.returns(false)
      local before, after = snippets.comment_string()
      assert.equals("-- ", before)
      assert.is_nil(after)
    end)

    it("returns before and after for block comments", function()
      vim.o.cms = "/* %s */"
      highlight_at_pos_contains.returns(false)
      local before, after = snippets.comment_string()
      assert.equals("/* ", before)
      assert.equals(" */", after)
    end)

    it("pads comment characters if they don't have spaces", function()
      vim.o.cms = "/*%s*/"
      highlight_at_pos_contains.returns(false)
      local before, after = snippets.comment_string()
      assert.equals("/* ", before)
      assert.equals(" */", after)
    end)
  end)
end)
