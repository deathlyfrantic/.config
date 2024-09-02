local indent_object = require("text-objects.indent")
local test_utils = require("test-utils")

describe("indent object", function()
  local test_text = [[
    level 0 - line 1
      level 1 - line 2
        level 2 - line 3
        level 2 - line 4
          level 3 - line 5
          level 3 - line 6
            level 4 - line 7
          level 3 - line 8
        level 2 - line 9
      level 1 - line 10]]

  before_each(function()
    test_utils.set_buf(test_text)
  end)

  after_each(function()
    test_utils.clear_buf()
  end)

  local function trigger_object()
    indent_object.textobject()
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
  end

  ---@param region integer[]
  local function assert_region(region)
    assert.equals(
      region[1],
      vim.api.nvim_buf_get_mark(0, "<")[1],
      "top of region is incorrect"
    )
    assert.equals(
      region[2],
      vim.api.nvim_buf_get_mark(0, ">")[1],
      "bottom of region is incorrect"
    )
  end

  -- maps line (index of list) to expected region as { top, bottom }
  local test_cases = {
    { 1, 10 },
    { 2, 10 },
    { 3, 9 },
    { 3, 9 },
    { 5, 8 },
    { 5, 8 },
    { 7, 7 },
    { 5, 8 },
    { 3, 9 },
    { 2, 10 },
  }

  it("selects correct regions", function()
    for line, region in pairs(test_cases) do
      test_utils.set_cursor(line)
      trigger_object()
      assert_region(region)
    end
  end)

  it("handles blank lines", function()
    local test_cases_with_blank = vim.deepcopy(test_cases)
    vim.api.nvim_buf_set_lines(0, 5, 6, false, { "" })
    test_cases_with_blank[6] = { 7, 7 }
    for line, region in pairs(test_cases_with_blank) do
      test_utils.set_cursor(line)
      trigger_object()
      assert_region(region)
    end
  end)

  it("handles blank lines with tabs", function()
    local test_cases_with_blank = vim.deepcopy(test_cases)
    vim.api.nvim_buf_set_lines(0, 5, 6, false, { "\t" })
    test_cases_with_blank[6] = { 7, 7 }
    for line, region in pairs(test_cases_with_blank) do
      test_utils.set_cursor(line)
      trigger_object()
      assert_region(region)
    end
  end)

  it("handles blank lines longer than non-blank lines", function()
    local test_cases_with_blank = vim.deepcopy(test_cases)
    vim.api.nvim_buf_set_lines(0, 5, 6, false, { "  \t  \t" })
    test_cases_with_blank[6] = { 7, 7 }
    for line, region in pairs(test_cases_with_blank) do
      test_utils.set_cursor(line)
      trigger_object()
      assert_region(region)
    end
  end)
end)
