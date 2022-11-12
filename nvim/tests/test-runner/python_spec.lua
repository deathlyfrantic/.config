local stub = require("luassert.stub")
local match = require("luassert.match")
local dedent = require("plenary.strings").dedent
local python = require("z.test-runner.python")

local function set_cursor(row, col)
  vim.api.nvim_win_set_cursor(0, { row, col or 0 })
end

describe("test-runner/python", function()
  local template = dedent([[
    class TestFoo:
        def test_in_class1():
            pass

        def test_in_class2():
            pass

        def not_a_test_in_a_class():
            pass


    class NotATestClass:
        def test_not_a_test_class():
            pass


    def test_bare1():
        pass


    def test_bare2():
        pass


    def not_a_test():
        pass]])

  before_each(function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, template:split("\n"))
    vim.bo.filetype = "python"
  end)

  after_each(function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
    -- doing it this way prevents the "unknown filetype" error from printing
    vim.cmd("silent! setlocal filetype ''")
  end)

  describe("treesitter", function()
    it("finds the correct test based on cursor position", function()
      local test_cases = {
        { 1, "test_in_class1" },
        { 2, "test_in_class1" },
        { 3, "test_in_class1" },
        { 4, "test_in_class1" },
        { 5, "test_in_class2" },
        { 8, "test_in_class2" },
        { 13, "test_in_class2" },
        { 16, "test_in_class2" },
        { 17, "test_bare1" },
        { 21, "test_bare2" },
        { 25, "test_bare2" },
      }
      for _, test_case in ipairs(test_cases) do
        local line, expected = unpack(test_case)
        set_cursor(line)
        assert.equals(expected, python.find_nearest_treesitter())
      end
    end)

    it("returns nil if a test can't be found", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
      assert.is_nil(python.find_nearest_treesitter())
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
      set_cursor(3)
      assert.equals("test_in_class1", python.find_nearest_regex())
      assert.stub(notify).called_with(match.string(), vim.log.levels.ERROR)
    end)

    it("finds the correct test based on cursor position", function()
      local test_cases = {
        { 1, "test_in_class1" },
        { 2, "test_in_class1" },
        { 3, "test_in_class1" },
        { 4, "test_in_class1" },
        { 5, "test_in_class2" },
        { 8, "test_in_class2" },
        -- no easy way to rule this one out via regex
        { 13, "test_not_a_test_class" },
        { 16, "test_not_a_test_class" },
        { 17, "test_bare1" },
        { 21, "test_bare2" },
        { 25, "test_bare2" },
      }
      for _, test_case in ipairs(test_cases) do
        local line, expected = unpack(test_case)
        set_cursor(line)
        assert.equals(expected, python.find_nearest_regex())
      end
    end)
  end)

  describe("pytest", function()
    local nvim_buf_get_name

    before_each(function()
      nvim_buf_get_name =
        stub(vim.api, "nvim_buf_get_name").returns("/foobar/file.py")
    end)

    after_each(function()
      nvim_buf_get_name:revert()
    end)

    it("returns command for nearest", function()
      assert.equals(
        "pytest /foobar/file.py::test_in_class1",
        python.pytest("nearest")
      )
    end)

    it("returns command for file", function()
      assert.equals("pytest /foobar/file.py", python.pytest("file"))
    end)

    it("returns generic command for 'all' selection", function()
      assert.equals("pytest", python.pytest("all"))
    end)

    it("returns generic test command if nearest test is nil", function()
      local notify = stub(vim, "notify")
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
      assert.equals("pytest", python.pytest("nearest"))
      notify:revert()
    end)
  end)

  describe("test command", function()
    local executable

    before_each(function()
      executable = stub(vim.fn, "executable")
    end)

    after_each(function()
      executable:revert()
    end)

    it("returns pytest command if `pytest` is executable", function()
      executable.returns(1)
      assert.equals("pytest", python.test("all"))
    end)

    it("returns unittest command if `pytest` is not executable", function()
      executable.returns(0)
      assert.equals("python3 -m unittest", python.test("all"))
    end)
  end)
end)
