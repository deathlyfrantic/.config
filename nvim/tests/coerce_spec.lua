local coerce = require("coerce")

describe("coerce", function()
  describe("camel and mixed", function()
    local test_cases = {
      foo_bar_baz = "fooBarBaz",
      foo__bar__baz = "foo_bar_baz",
      fooBar__baz_quux = "foobar_bazQuux",
      foo__bar_baz = "foo_barBaz",
      foobarbaz = "foobarbaz",
      Foo_Bar_Baz = "fooBarBaz",
      FooBarBaz = "fooBarBaz",
    }

    it("camel case", function()
      for test, expected in pairs(test_cases) do
        assert.equals(expected, coerce.camel_case(test))
      end
    end)

    it("mixed case", function()
      for test, expected in pairs(test_cases) do
        assert.equals(
          expected:sub(1, 1):upper() .. expected:sub(2),
          coerce.mixed_case(test)
        )
      end
    end)
  end)

  describe("snake and related", function()
    local test_cases = {
      ["Foo::BarBaz"] = "foo/bar_baz",
      fooBarBAZQuux = "foo_bar_baz_quux",
      fooBar123Baz_Quux = "foo_bar123_baz_quux",
      FooBar = "foo_bar",
      foo_bar_baz = "foo_bar_baz",
      foo__bar__baz = "foo__bar__baz",
    }

    it("snake case", function()
      for test, expected in pairs(test_cases) do
        assert.equals(expected, coerce.snake_case(test))
      end
    end)

    it("dash case", function()
      for test, expected in pairs(test_cases) do
        assert.equals(expected:gsub("_", "-"), coerce.dash_case(test))
      end
    end)

    it("dot case", function()
      for test, expected in pairs(test_cases) do
        assert.equals(expected:gsub("_", "."), coerce.dot_case(test))
      end
    end)

    it("space case", function()
      for test, expected in pairs(test_cases) do
        assert.equals(expected:gsub("_", " "), coerce.space_case(test))
      end
    end)

    it("upper case", function()
      for test, expected in pairs(test_cases) do
        assert.equals(expected:upper(), coerce.upper_case(test))
      end
    end)
  end)
end)
