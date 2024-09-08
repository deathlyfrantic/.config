local variable_segment_object = require("text-objects.variable-segment")
local test_utils = require("test-utils")

describe("variable-segment object", function()
  after_each(function()
    test_utils.clear_buf()
  end)

  ---@param mode? "i" | "a"
  ---@param count? integer
  local function trigger_object(mode, count)
    variable_segment_object.textobject(mode or "i", count)
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
  end

  ---@param left integer
  ---@param right integer
  local function assert_region(left, right)
    assert.equals(
      left,
      vim.api.nvim_buf_get_mark(0, "<")[2],
      "left side of region is incorrect"
    )
    assert.equals(
      right,
      vim.api.nvim_buf_get_mark(0, ">")[2],
      "right side of region is incorrect"
    )
  end

  ---@param text string
  ---@return { cursor: integer, left: integer, right: integer, text: string }
  local function find_positions(text)
    local left, _ = text:find("%[")
    local cursor, _ = text:find("|")
    local right, _ = text:find("%]")
    return {
      -- subtract 1 to convert from 1-indexed (lua) to 0-indexed (columns)
      left = left - 1,
      -- subtract 1 for indexing, 1 because left was removed before this
      cursor = cursor - 2,
      -- subtract 4:
      -- - 1 for indexing
      -- - 1 for left being removed
      -- - 1 for cursor being removed
      -- - 1 for moving cursor back to last part of match
      right = right - 4,
      text = text:gsub("[%[|%]]", ""),
    }
  end

  ---@param text string
  ---@param mode? "i" | "a"
  ---@param count? integer
  ---@return function
  local function test(text, mode, count)
    return function()
      local positions = find_positions(text)
      test_utils.set_buf(positions.text)
      test_utils.set_cursor(1, positions.cursor)
      trigger_object(mode, count)
      assert_region(positions.left, positions.right)
    end
  end

  describe("without count", function()
    local test_cases = {
      "foo_[b|ar]_baz",
      "[f|oo]_bar_baz",
      "foo_bar_[b|az]",
      "foo[B|ar]Baz",
      "777[Foo|bar]",
      "Foobar[7|77]",
      "FOO[1|23]BAR",
      "Foo[BA|R]Baz",
      "FooBAR[B|az]",
      "_[f|oo]_bar",
      "_[f|oo]BarBaz",
      "__[f|oo]BarBaz",
      "[fo|o]BarBaz",
      "[F|oo]Bar",
      "FOO_[B|AR]_BAZ",
      "fooBar_[B|az]Quux",
      "[foo|]_bar",
      "[|foo]_bar",
      "foo_[bar|]",
      "[|foo]Bar",
      "foo[Bar|]",
      "[|f]_bar_baz",
      "[|f]BarBaz",
      "f_[b|ar]_baz",
      "f[B|ar]Baz",
      "foo_bar [b|az]_quux",
      "foo_[b|ar] baz_quux",
      "fooBar [b|az]Quux",
      "foo[B|ar] bazQuux",
      "[f|oo] bar",
      "[f|oo]",
    }

    for _, text in ipairs(test_cases) do
      it(text, test(text))
    end
  end)

  describe("with count", function()
    local test_cases = {
      ["foo_[b|ar_baz]"] = 2,
      ["Foo[B|arBaz]"] = 2,
      ["[|foo_bar] baz"] = 3,
      ["[|foo______bar]"] = 2,
      ["[|foo_bar]"] = 9,
      ["[f|oo_777]_bar"] = 2,
      ["foo_[7|77]_bar"] = 1,
      ["[|foo_barBaz]_quux"] = 3,
      ["foo_[b|ar_bazQuux777Garply_waldo]_fred"] = 6,
    }

    for text, count in pairs(test_cases) do
      it(("%s, count %s"):format(text, count), test(text, "i", count))
    end
  end)

  describe("'a' mode", function()
    local test_cases = {
      "[|foo_]bar",
      "[f|oo_____]bar",
      "foo_[77|7_]bar",
      "[f|oo]Bar",
      "[f|oo_] bar",
      "[f|oo]",
    }

    for _, text in ipairs(test_cases) do
      it(text, test(text, "a"))
    end
  end)

  describe("'a' mode, supports count", function()
    local test_cases = {
      ["[|foo_bar_]baz"] = 2,
      ["[f|oo_____]bar"] = 1,
      ["foo_[77|7_bar]"] = 2,
      ["[f|oo_barBaz]"] = 3,
      ["[f|oo_] bar"] = 7,
      ["foo_[b|ar_bazQuux777Garply_waldo_]fred"] = 6,
    }

    for text, count in pairs(test_cases) do
      it(("%s, count %s"):format(text, count), test(text, "a", count))
    end
  end)
end)
