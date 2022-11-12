local stub = require("luassert.stub")
local match = require("luassert.match")
local rust = require("z.test-runner.rust")
local utils = require("z.test-utils")

describe("test-runner/rust", function()
  local template = [[
    #[cfg(test)]
    mod tests {
      use super::*;

      #[test]
      fn test_foo() {
        // ...
      }

      #[test]
      fn test_bar() {
        // ...
      }
    }]]

  before_each(function()
    utils.set_buf(template)
    vim.bo.filetype = "rust"
  end)

  after_each(function()
    utils.clear_buf()
    utils.clear_filetype()
  end)

  describe("treesitter", function()
    it("finds the correct test based on cursor position", function()
      local test_cases = {
        { 1, "test_foo" },
        { 7, "test_foo" },
        { 9, "test_foo" },
        { 11, "test_bar" },
        { 14, "test_bar" },
      }
      for _, test_case in ipairs(test_cases) do
        local line, expected = unpack(test_case)
        utils.set_cursor(line)
        assert.equals(expected, rust.find_nearest_treesitter())
      end
    end)

    it("returns nil if it cannot find a test", function()
      utils.clear_buf()
      utils.set_cursor(1)
      assert.is_nil(rust.find_nearest_treesitter())
    end)
  end)

  describe("regex", function()
    local notify

    before_each(function()
      notify = stub(vim, "notify")
    end)

    after_each(function()
      notify:revert()
    end)

    it("logs error if called (because treesitter didn't find test)", function()
      utils.set_cursor(1)
      assert.equals("test_foo", rust.find_nearest_regex())
      assert.stub(notify).called_with(match.string(), vim.log.levels.ERROR)
    end)

    it("finds the correct test based on cursor position", function()
      local test_cases = {
        { 1, "test_foo" },
        { 7, "test_foo" },
        { 9, "test_foo" },
        { 11, "test_bar" },
        { 14, "test_bar" },
      }
      for _, test_case in ipairs(test_cases) do
        local line, expected = unpack(test_case)
        utils.set_cursor(line)
        assert.equals(expected, rust.find_nearest_regex())
      end
    end)

    it("returns nil if it cannot find a test", function()
      utils.clear_buf()
      utils.set_cursor(1)
      assert.is_nil(rust.find_nearest_regex())
    end)
  end)

  describe("test command", function()
    local nvim_buf_get_name

    before_each(function()
      nvim_buf_get_name =
        stub(vim.api, "nvim_buf_get_name").returns("/foobar/src/file.rs")
    end)

    after_each(function()
      nvim_buf_get_name:revert()
    end)

    it("returns nil if cargo is not found", function()
      local executable = stub(vim.fn, "executable").returns(0)
      assert.is_nil(rust.test())
      executable:revert()
    end)

    it("returns command for all tests if it can't find nearest", function()
      local search = stub(vim.fn, "search").returns(0)
      assert.equals("(cd /foobar && cargo test)", rust.test("nearest"))
      search:revert()
    end)

    it("returns command for a specific test", function()
      utils.set_cursor(1)
      assert.equals("(cd /foobar && cargo test test_foo)", rust.test("nearest"))
    end)

    it("returns command for file", function()
      assert.equals("(cd /foobar && cargo test file::)", rust.test("file"))
    end)

    it("returns command for all tests", function()
      assert.equals("(cd /foobar && cargo test)", rust.test("all"))
    end)
  end)
end)
