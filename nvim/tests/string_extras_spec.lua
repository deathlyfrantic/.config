local spy = require("luassert.spy")

describe("string_extras", function()
  require("string_extras")

  it("trim", function()
    local trim = spy.on(vim.fn, "trim")
    local s = "foobar    "
    assert.equals(s:trim(), "foobar")
    assert.spy(trim).called(1)
  end)

  it("split", function()
    local s = "foo|bar|baz"
    assert.same(s:split("|"), { "foo", "bar", "baz" })
  end)

  it("is_empty", function()
    assert.is_false(("foobar"):is_empty())
    assert.is_true((""):is_empty())
    assert.is_true((" "):is_empty())
    assert.is_true(("\t"):is_empty())
    assert.is_true(("  \t    "):is_empty())
  end)

  describe("pad", function()
    local s = "foobar"
    local fmt

    before_each(function()
      fmt = spy.on(string, "format")
    end)

    after_each(function()
      fmt:clear()
    end)

    it("pads on correct sides with correct padding", function()
      assert.equals(s:lpad(8, "|"), "||foobar")
      assert.equals(s:rpad(8, "|"), "foobar||")
    end)

    it("does nothing if trying to pad to less than current length", function()
      assert.equals(s:lpad(1, "|"), s)
    end)

    it("uses string.format for padding with spaces", function()
      assert.equals(s:lpad(8, " "), "  foobar")
      assert.spy(fmt).called_with("%8s", "foobar")
      assert.equals(s:rpad(8, " "), "foobar  ")
      assert.spy(fmt).called_with("%-8s", "foobar")
    end)

    it("deals with multi-char whitespace padding", function()
      assert.equals(s:lpad(8, " \t "), "  foobar")
      assert.spy(fmt).called_with("%8s", "foobar")
      assert.equals(s:rpad(8, " \t "), "foobar  ")
      assert.spy(fmt).called_with("%-8s", "foobar")
    end)

    it("deals with multi-char padding", function()
      assert.equals(s:lpad(8, "123"), "12foobar")
      assert.equals(s:rpad(13, "123"), "foobar1231231")
    end)
  end)

  it("chars", function()
    -- should be an iterator
    local s = "foobar"
    for i, c in s:chars() do
      assert.equals(c, s:sub(i, i))
    end
  end)
end)
