local stub = require("luassert.stub")
local test_utils = require("test-utils")

describe("sort command", function()
  -- load plugin before running tests
  vim.cmd.source(
    vim.fs.joinpath(vim.fn.stdpath("config"), "plugin", "sort-command.lua")
  )

  local notify

  before_each(function()
    notify = stub(vim, "notify")
  end)

  after_each(function()
    notify:revert()
    test_utils.clear_buf()
  end)

  it("errors with on multiple line selections", function()
    local lines = { "foo, bar, baz", "quux, garply, xyzzy" }
    test_utils.set_buf(lines)
    test_utils.set_visual_marks({ 1, 0 }, { 2, 2147483647 })
    vim.cmd.Sort()
    assert.stub(notify).called_with(
      "This command does not work on multiline selections.",
      vim.log.levels.ERROR
    )
    assert.same(test_utils.get_buf(), lines)
  end)

  it("determines separator if not provided", function()
    local line = "foo|bar|baz|quux|garply"
    test_utils.set_buf(line)
    test_utils.set_visual_marks({ 1, 0 }, { 1, #line - 1 })
    vim.cmd.Sort()
    assert.equal("bar|baz|foo|garply|quux", test_utils.get_buf()[1])
  end)

  it("uses space as separator if there is no punctuation", function()
    local line = "foo bar baz quux garply"
    test_utils.set_buf(line)
    test_utils.set_visual_marks({ 1, 0 }, { 1, #line - 1 })
    vim.cmd.Sort()
    assert.equal("bar baz foo garply quux", test_utils.get_buf()[1])
  end)

  it("does nothing if there are no punctuation characters or spaces", function()
    local line = "foobarbazquuxgarply"
    test_utils.set_buf(line)
    test_utils.set_visual_marks({ 1, 0 }, { 1, #line - 1 })
    vim.cmd.Sort()
    assert.equal(line, test_utils.get_buf()[1])
  end)

  it("sorts based on provided separator", function()
    local line = "foo, bar, | baz, quux, garply"
    test_utils.set_buf(line)
    test_utils.set_visual_marks({ 1, 0 }, { 1, #line - 1 })
    vim.cmd.Sort("|")
    assert.equal("baz, quux, garply | foo, bar,", test_utils.get_buf()[1])
  end)

  it("works with multi-character separators", function()
    local line = "foo XXX bar XXX baz XXX quux XXX garply"
    test_utils.set_buf(line)
    test_utils.set_visual_marks({ 1, 0 }, { 1, #line - 1 })
    vim.cmd.Sort("XXX")
    assert.equal(
      "bar XXX baz XXX foo XXX garply XXX quux",
      test_utils.get_buf()[1]
    )
  end)

  describe("spacing around separator", function()
    it("no spacing", function()
      local line = "foo,bar,baz,quux,garply"
      test_utils.set_buf(line)
      test_utils.set_visual_marks({ 1, 0 }, { 1, #line - 1 })
      vim.cmd.Sort()
      assert.equal("bar,baz,foo,garply,quux", test_utils.get_buf()[1])
    end)

    it("trailing spaces", function()
      local line = "foo, bar, baz, quux, garply"
      test_utils.set_buf(line)
      test_utils.set_visual_marks({ 1, 0 }, { 1, #line - 1 })
      vim.cmd.Sort()
      assert.equal("bar, baz, foo, garply, quux", test_utils.get_buf()[1])
    end)

    it("leading spaces", function()
      local line = "foo ,bar ,baz ,quux ,garply"
      test_utils.set_buf(line)
      test_utils.set_visual_marks({ 1, 0 }, { 1, #line - 1 })
      vim.cmd.Sort()
      assert.equal("bar ,baz ,foo ,garply ,quux", test_utils.get_buf()[1])
    end)

    it("both trailing and leading spaces", function()
      local line = "foo | bar | baz | quux | garply"
      test_utils.set_buf(line)
      test_utils.set_visual_marks({ 1, 0 }, { 1, #line - 1 })
      vim.cmd.Sort()
      assert.equal("bar | baz | foo | garply | quux", test_utils.get_buf()[1])
    end)

    it("collapses multiple spaces", function()
      local line = "foo   |   bar   |   baz   |   quux   |   garply"
      test_utils.set_buf(line)
      test_utils.set_visual_marks({ 1, 0 }, { 1, #line - 1 })
      vim.cmd.Sort()
      assert.equal("bar | baz | foo | garply | quux", test_utils.get_buf()[1])
    end)
  end)

  it("sorts in reverse", function()
    local line = "foo, bar, baz, quux, garply"
    test_utils.set_buf(line)
    test_utils.set_visual_marks({ 1, 0 }, { 1, #line - 1 })
    vim.cmd.Sort({ bang = true })
    assert.equal("quux, garply, foo, baz, bar", test_utils.get_buf()[1])
  end)

  it("works as an operator", function()
    local line = "foo, bar, baz, quux, garply"
    test_utils.set_buf(line)
    test_utils.set_cursor()
    vim.api.nvim_feedkeys("gS$", "mx", true)
    assert.equal("bar, baz, foo, garply, quux", test_utils.get_buf()[1])
  end)
end)
