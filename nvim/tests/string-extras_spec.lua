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
    assert.same((":aa::b:"):split(":"), { "", "aa", "", "b", "" })
    assert.same(("axaby"):split("ab?"), { "", "x", "y" })
    assert.same(("x*yz*o"):split("*", { plain = true }), { "x", "yz", "o" })
    assert.same(("|x|y|z|"):split("|", { trimempty = true }), { "x", "y", "z" })
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
  end)
end)
