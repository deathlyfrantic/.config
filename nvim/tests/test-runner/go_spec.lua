local stub = require("luassert.stub")
local match = require("luassert.match")
local go = require("test-runner.go")
local test_utils = require("test-utils")
local utils = require("utils")

describe("test-runner/go", function()
  local template = [[
    package main

    import "testing"

    func Test1(t *testing.T) {
    	// ...
    }

    func Test2(t *testing.T) {
    	// ...
    }

    func Test3(t *testing.T) {
    	// ...
    }
  ]]

  before_each(function()
    test_utils.set_buf(template)
    vim.bo.filetype = "go"
  end)

  after_each(function()
    test_utils.clear_buf()
    test_utils.clear_filetype()
  end)

  describe("treesitter", function()
    it("finds the correct test based on cursor position", function()
      local test_cases = {
        { "Test1", 1, 8 },
        { "Test2", 9, 12 },
        { "Test3", 13, 15 },
      }
      for _, test_case in ipairs(test_cases) do
        local expected, start, stop = unpack(test_case)
        for i = start, stop do
          test_utils.set_cursor(i)
          assert.equals(expected, go.find_nearest_treesitter())
        end
      end
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
      test_utils.set_cursor(6)
      assert.equals("Test1", go.find_nearest_regex())
      assert.stub(notify).called_with(match.string(), vim.log.levels.ERROR)
    end)

    it("finds the correct test based on cursor position", function()
      local test_cases = {
        { "Test1", 1, 8 },
        { "Test2", 9, 12 },
        { "Test3", 13, 15 },
      }
      for _, test_case in ipairs(test_cases) do
        local expected, start, stop = unpack(test_case)
        for i = start, stop do
          test_utils.set_cursor(i)
          assert.equals(expected, go.find_nearest_regex())
        end
      end
    end)
  end)

  describe("test command", function()
    local nvim_buf_get_name
    local find_project_dir

    before_each(function()
      nvim_buf_get_name =
        stub(vim.api, "nvim_buf_get_name").returns("/foobar/src/file_test.go")
      find_project_dir = stub(utils, "find_project_dir").returns("/foobar/")
    end)

    after_each(function()
      nvim_buf_get_name:revert()
      find_project_dir:revert()
    end)

    it("returns command for all tests if it can't find nearest", function()
      local find_nearest_treesitter =
        stub(go, "find_nearest_treesitter").returns(nil)
      local find_nearest_regex = stub(go, "find_nearest_regex").returns(nil)
      assert.equals('go test -v "/foobar/..."', go.test("nearest"))
      find_nearest_treesitter:revert()
      find_nearest_regex:revert()
    end)

    it("returns command for a specific test", function()
      test_utils.set_cursor(6)
      assert.equals('go test -v "/foobar/src" -run Test1', go.test("nearest"))
    end)

    it("returns command for file", function()
      assert.equals('go test -v "/foobar/src"', go.test("file"))
    end)

    it("returns command for all tests", function()
      assert.equals('go test -v "/foobar/..."', go.test("all"))
    end)

    it(
      "returns file test command if current filename doesn't include `_test`",
      function()
        stub(vim.api, "nvim_buf_get_name").returns("/foobar/src/file.go")
        assert.equals('go test -v "/foobar/src"', go.test("file"))
      end
    )
  end)
end)
