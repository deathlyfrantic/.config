local spy = require("luassert.spy")

describe("string-extras", function()
  require("string-extras")

  it("trim", function()
    local trim = spy.on(vim.fn, "trim")
    local s = "foobar    "
    assert.equals(s:trim(), "foobar")
    assert.spy(trim).called(1)
  end)

  it("is_empty", function()
    assert.is_false(("foobar"):is_empty())
    assert.is_true((""):is_empty())
    assert.is_true((" "):is_empty())
    assert.is_true(("\t"):is_empty())
    assert.is_true(("  \t    "):is_empty())
  end)

  it("split", function()
    assert.same(
      (":aa::b:"):split(":", { trimempty = false }),
      { "", "aa", "", "b", "" }
    )
    assert.same(("xayabz"):split("ab?", { plain = false }), { "x", "y", "z" })
    assert.same(("x*yz*o"):split("*"), { "x", "yz", "o" })
    assert.same(("|x|y|z|"):split("|"), { "x", "y", "z" })
  end)

  it("starts_with", function()
    assert.is_true(("foobar"):starts_with("foo"))
    assert.is_false(("foobar"):starts_with("qqq"))
  end)

  it("ends_with", function()
    assert.is_true(("foobar"):ends_with("bar"))
    assert.is_false(("foobar"):ends_with("qqq"))
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

  describe("imatch", function()
    it("matches case-insensitively", function()
      local test_cases = { "FOOBAR", "foobar", "FoObAr", "fOoBaR" }
      for _, test_case in ipairs(test_cases) do
        assert.equals(test_case, test_case:imatch("foobar"))
      end
    end)

    it("doesn't match if pattern isn't in string", function()
      assert.falsy(("foobar"):imatch("baz"))
    end)

    describe("supports (most?) normal patterns", function()
      local match

      before_each(function()
        match = spy.on(string, "match")
      end)

      after_each(function()
        match:revert()
      end)

      it("works with % patterns", function()
        assert.truthy(("123FoObAr"):imatch("%d*foobar"))
        assert
          .spy(match)
          .called_with("123FoObAr", "%d*[Ff][Oo][Oo][Bb][Aa][Rr]")
      end)

      it("works with [] patterns", function()
        local pattern = "[AbCdEf]"
        assert.truthy(("A"):imatch(pattern))
        assert.spy(match).called_with("A", pattern)
        assert.falsy(("B"):imatch(pattern))
      end)

      it("works with captures", function()
        assert.equals("FoO", ("FoObAr"):imatch("(foo)bar"))
        assert.spy(match).called_with("FoObAr", "([Ff][Oo][Oo])[Bb][Aa][Rr]")
      end)

      it("works with complicated patterns", function()
        local pattern = "^[+-]?%d+$"
        for _, test in ipairs({ "-123", "+456", "789" }) do
          assert.equals(test, test:imatch(pattern))
          assert.spy(match).called_with(test, pattern)
          match:clear()
        end
      end)
    end)

    it("caches patterns", function()
      assert.equals("fOoBaR", ("fOoBaR"):imatch("foobar"))
      local chars = spy.on(string, "chars")
      assert.equals("fOoBaR", ("fOoBaR"):imatch("foobar"))
      assert.spy(chars).not_called()
    end)
  end)

  describe("dedent", function()
    it("removes common whitespace from beginning of lines", function()
      assert.equals("foo\n bar\n  baz", ("  foo\n   bar\n    baz"):dedent())
      assert.equals("foo\nbar\nbaz", (" foo\n bar\n baz"):dedent())
    end)

    it("does not remove anything from lines that aren't indented", function()
      local s = "foo\n bar\n  baz"
      assert.equals(s, s:dedent())
    end)

    it("works with tabs", function()
      local s = "\t   foo\n\t \tbar\n\t\t\t baz\tquux"
      assert.equals("  foo\n\tbar\n\t\tbaz\tquux", s:dedent())
    end)

    it("puts tabs at beginning even if interleaved with spaces", function()
      local s = "\t foo\n\t  \t bar"
      assert.equals("foo\n\t  bar", s:dedent())
    end)

    it("ignores empty lines", function()
      local s = "foo\n\n  bar"
      assert.equals("foo\n\n  bar", s:dedent())
    end)
  end)

  it("visual_indent", function()
    local test_cases = {
      [""] = 0,
      foo = 0,
      [" foo"] = 1,
      ["  foo"] = 2,
      ["\tfoo"] = 8,
      [" \tfoo"] = 8,
      ["\t\tfoo"] = 16,
      [" \t\tfoo"] = 16,
      [" \t \tfoo"] = 16,
    }
    for s, expected in pairs(test_cases) do
      assert.equals(expected, s:visual_indent())
    end
  end)

  describe("splitlines", function()
    -- selene: allow(bad_string_escape)
    local newline_separators = {
      ["\n"] = [[\n]],
      ["\r"] = [[\r]],
      ["\r\n"] = [[\r\n]],
      ["\v"] = [[\v]],
      ["\f"] = [[\f]],
      ["\x1c"] = [[\x1c]],
      ["\x1d"] = [[\x1d]],
      ["\x1e"] = [[\x1e]],
      ["\x85"] = [[\x85]],
      ["\u{2028}"] = [[\u{2028}]],
      ["\u{2029}"] = [[\u{2029}]],
    }

    for char, repr in pairs(newline_separators) do
      it(("splitlines, char '%s'"):format(repr), function()
        local pieces = { "foo", "", "bar", "", "", "baz" }
        local test_string = table.concat(pieces, char)
        assert.same(pieces, test_string:splitlines())
      end)
    end
  end)
end)
