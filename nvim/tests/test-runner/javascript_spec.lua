local stub = require("luassert.stub")
local match = require("luassert.match")
local javascript = require("test-runner.javascript")
local utils = require("test-utils")

describe("test-runner/javascript", function()
  local template = [[
    describe("tests", () => {
      it("test1", () => {
        // ...
      });

      test('test2', async () => {
        // ...
      });

      context("test3", function() {
        // ...
      });

      it(`test4`, () => {
        // ...
      });

      it(test5(), {
        // ...
      });
    });

    ]]

  before_each(function()
    utils.set_buf(template)
    vim.bo.filetype = "javascript"
  end)

  after_each(function()
    utils.clear_buf()
    utils.clear_filetype()
  end)

  describe("treesitter", function()
    it("finds the correct test based on cursor position", function()
      local test_cases = {
        { 1, "tests" },
        { 3, "test1" },
        { 5, "test1" },
        { 7, "test2" },
        { 11, "test3" },
        { 15, "test3" },
        { 19, "test3" },
      }
      for _, test_case in ipairs(test_cases) do
        local line, expected = unpack(test_case)
        utils.set_cursor(line)
        assert.equals(expected, javascript.find_nearest_treesitter())
      end
    end)

    it("returns nil if cursor is not in test/describe block", function()
      utils.clear_buf()
      assert.is_nil(javascript.find_nearest_treesitter())
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
      utils.set_cursor(3)
      assert.equals("test1", javascript.find_nearest_regex())
      assert.stub(notify).called_with(match.string(), vim.log.levels.ERROR)
    end)

    it("finds the correct test based on cursor position", function()
      local test_cases = {
        { 1, "tests" },
        { 2, "test1" },
        { 4, "test1" },
        { 7, "test2" },
        { 9, "test2" }, -- finds previous test instead
        { 11, "test3" },
        { 15, "test3" }, -- finds previous test instead
        { 19, "test3" }, -- finds previous test instead
        { 22, "test3" }, -- finds previous test instead
      }
      for _, test_case in ipairs(test_cases) do
        local line, expected = unpack(test_case)
        utils.set_cursor(line)
        assert.equals(expected, javascript.find_nearest_regex())
      end
    end)

    it("returns nil if it can't find a test", function()
      utils.clear_buf()
      assert.is_nil(javascript.find_nearest_regex())
    end)
  end)

  describe("npm or yarn", function()
    local find

    before_each(function()
      find = stub(vim.fs, "find")
    end)

    after_each(function()
      find:revert()
      vim.b.z_test_runner_npm_or_yarn = nil
    end)

    it("returns yarn if a yarn.lock file is found", function()
      find.returns({ "yarn.lock" })
      assert.equals("yarn", javascript.npm_or_yarn())
    end)

    it("returns npm if a yarn.lock file is not found", function()
      find.returns({})
      assert.equals("npm", javascript.npm_or_yarn())
    end)

    it("caches value per buffer", function()
      assert.is_nil(vim.b.z_test_runner_npm_or_yarn)
      find.returns({})
      assert.equals("npm", javascript.npm_or_yarn())
      assert.equals(vim.b.z_test_runner_npm_or_yarn, "npm")
    end)
  end)

  describe("mocha", function()
    local nvim_buf_get_name

    before_each(function()
      nvim_buf_get_name =
        stub(vim.api, "nvim_buf_get_name").returns("/foobar/file.js")
    end)

    after_each(function()
      nvim_buf_get_name:revert()
    end)

    it("returns command for nearest", function()
      utils.set_cursor(3)
      assert.equals(
        "npx mocha -- spec /foobar/file.js --grep='test1'",
        javascript.mocha("nearest")
      )
    end)

    it("adds pretest if provided", function()
      utils.set_cursor(3)
      assert.equals(
        "pretest && npx mocha -- spec /foobar/file.js --grep='test1'",
        javascript.mocha("nearest", "pretest")
      )
    end)

    it("returns file command for 'file' selection", function()
      assert.equals(
        "npx mocha -- spec /foobar/file.js",
        javascript.mocha("file")
      )
    end)

    it("returns generic command for 'all' selection", function()
      assert.equals("npm test", javascript.mocha("all"))
    end)

    it("returns generic test command if nearest test is nil", function()
      local notify = stub(vim, "notify")
      utils.clear_buf()
      assert.equals("npm test", javascript.mocha("nearest"))
      notify:revert()
    end)
  end)

  describe("jest", function()
    local nvim_buf_get_name

    before_each(function()
      nvim_buf_get_name =
        stub(vim.api, "nvim_buf_get_name").returns("/foobar/file.js")
    end)

    after_each(function()
      nvim_buf_get_name:revert()
    end)

    it("returns command for nearest", function()
      utils.set_cursor(3)
      assert.equals("npm test -- -t 'test1'", javascript.jest("nearest"))
    end)

    it("returns file command for 'file' selection", function()
      assert.equals("npm test -- /foobar/file.js", javascript.jest("file"))
    end)

    it("returns generic command for 'all' selection", function()
      assert.equals("npm test --", javascript.jest("all"))
    end)

    it("returns generic test command if nearest test is nil", function()
      local notify = stub(vim, "notify")
      utils.clear_buf()
      assert.equals("npm test --", javascript.jest("nearest"))
      notify:revert()
    end)
  end)

  describe("test command", function()
    local find, ioopen, nvim_buf_get_name

    local packagejson = [[
      {
        "scripts": {
          "pretest": "pretest.sh",
          "test": "%s"
        }
      }
    ]]

    before_each(function()
      find = stub(vim.fs, "find")
      ioopen = stub(io, "open")
      nvim_buf_get_name =
        stub(vim.api, "nvim_buf_get_name").returns("/foobar/file.js")
    end)

    after_each(function()
      find:revert()
      ioopen:revert()
      nvim_buf_get_name:revert()
    end)

    it("returns nil if package.json is not found", function()
      find.returns({})
      assert.is_nil(javascript.test())
    end)

    it(
      "returns mocha command if package.json scripts.test contains 'mocha'",
      function()
        utils.set_cursor(3)
        find.returns({ "/foobar/package.json" })
        ioopen.returns({
          read = function()
            return packagejson:format("foo mocha bar")
          end,
        })
        assert.equals(
          "pretest.sh && npx mocha -- spec /foobar/file.js --grep='test1'",
          javascript.test("nearest")
        )
      end
    )

    it(
      "returns jest command if package.json scripts.test contains 'jest'",
      function()
        utils.set_cursor(3)
        find.returns({ "/foobar/package.json" })
        ioopen.returns({
          read = function()
            return packagejson:format("foo jest bar")
          end,
        })
        assert.equals("npm test -- -t 'test1'", javascript.test("nearest"))
      end
    )

    it("returns generic test command for other cases", function()
      utils.set_cursor(3)
      find.returns({ "/foobar/package.json" })
      ioopen.returns({
        read = function()
          return packagejson:format("foo bar")
        end,
      })
      assert.equals("npm test", javascript.test("nearest"))
    end)
  end)
end)
