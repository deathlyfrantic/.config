local stub = require("luassert.stub")
local test_utils = require("test-utils")

describe("autoclose", function()
  -- load plugin before running tests
  vim.cmd.source(vim.fn.stdpath("config") .. "/plugin/autoclose.lua")

  -- easier to run the function directly than to use insert mode in a test
  local autoclose = test_utils.get_keymap_callback("i", "<Plug>autocloseCR")

  local get_cursor

  before_each(function()
    get_cursor = stub(vim.api, "nvim_win_get_cursor")
  end)

  after_each(function()
    test_utils.clear_buf()
    get_cursor:revert()
    test_utils.clear_filetype()
  end)

  it("closes", function()
    local line = "{"
    test_utils.set_buf(line)
    get_cursor.returns({ 1, #line })
    assert.same("<CR>}<C-o>O", autoclose())
  end)

  it("does not close if cursor is not at end of line", function()
    test_utils.set_buf("foo {")
    get_cursor.returns({ 1, 1 })
    assert.same("<CR>", autoclose())
  end)

  it("does not close if line does not end with left pair", function()
    local line = "foo { bar"
    test_utils.set_buf(line)
    get_cursor.returns({ 1, #line })
    assert.same("<CR>", autoclose())
  end)

  it("does not close if pair is already closed", function()
    test_utils.set_buf([[
      {

      }]])
    get_cursor.returns({ 1, 1 })
    assert.same("<CR>", autoclose())
  end)

  it("does not close if pair is already closed and it's complicated", function()
    test_utils.set_buf([[
      {
        (
          []
        )
      }
      ]])
    get_cursor.returns({ 1, 1 })
    assert.same("<CR>", autoclose())
  end)

  it("does not close pairs that are already closed on the same line", function()
    local line = "[({([)]}{"
    test_utils.set_buf(line)
    get_cursor.returns({ 1, #line })
    assert.same("<CR>})]<C-o>O", autoclose())
  end)

  it("closes multiple pairs in correct order", function()
    local line = "[{("
    test_utils.set_buf(line)
    get_cursor.returns({ 1, #line })
    assert.same("<CR>)}]<C-o>O", autoclose())
  end)

  it("closes event with trailing spaces", function()
    local line = "foo {          "
    test_utils.set_buf(line)
    get_cursor.returns({ 1, #line })
    assert.same("<CR>}<C-o>O", autoclose())
  end)

  it("does not close left pair in a string", function()
    vim.bo.filetype = "lua"
    local line = [[foo("bar {{ baz", {]]
    test_utils.set_buf(line)
    get_cursor.returns({ 1, #line })
    assert.same("<CR>})<C-o>O", autoclose())
  end)

  describe("adds semicolon", function()
    describe("javascript and typescript", function()
      before_each(function()
        vim.bo.filetype = "javascript"
      end)

      it("assignment", function()
        local line = "foo = {"
        test_utils.set_buf(line)
        get_cursor.returns({ 1, #line })
        assert.same("<CR>};<C-o>O", autoclose())
      end)

      it("return", function()
        local line = "return {"
        test_utils.set_buf(line)
        get_cursor.returns({ 1, #line })
        assert.same("<CR>};<C-o>O", autoclose())
      end)

      it("function call at start of line", function()
        local line = "foo.bar("
        test_utils.set_buf(line)
        get_cursor.returns({ 1, #line })
        assert.same("<CR>);<C-o>O", autoclose())
      end)

      it("awaited function call at start of line", function()
        local line = "await foo.bar("
        test_utils.set_buf(line)
        get_cursor.returns({ 1, #line })
        assert.same("<CR>);<C-o>O", autoclose())
      end)
    end)

    describe("rust", function()
      before_each(function()
        vim.bo.filetype = "rust"
      end)

      it("assignment", function()
        local line = "foo = {"
        test_utils.set_buf(line)
        get_cursor.returns({ 1, #line })
        assert.same("<CR>};<C-o>O", autoclose())
      end)

      it("return", function()
        local line = "return {"
        test_utils.set_buf(line)
        get_cursor.returns({ 1, #line })
        assert.same("<CR>};<C-o>O", autoclose())
      end)
    end)

    describe("c", function()
      before_each(function()
        vim.bo.filetype = "c"
      end)

      it("assignment", function()
        local line = "foo = {"
        test_utils.set_buf(line)
        get_cursor.returns({ 1, #line })
        assert.same("<CR>};<C-o>O", autoclose())
      end)

      it("return", function()
        local line = "return {"
        test_utils.set_buf(line)
        get_cursor.returns({ 1, #line })
        assert.same("<CR>};<C-o>O", autoclose())
      end)

      it("struct", function()
        local line = "struct {"
        test_utils.set_buf(line)
        get_cursor.returns({ 1, #line })
        assert.same("<CR>};<C-o>O", autoclose())
      end)

      it("enum", function()
        local line = "enum {"
        test_utils.set_buf(line)
        get_cursor.returns({ 1, #line })
        assert.same("<CR>};<C-o>O", autoclose())
      end)
    end)
  end)
end)
