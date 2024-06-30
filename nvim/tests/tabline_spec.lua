local stub = require("luassert.stub")
local tabline = require("tabline")

describe("tabline", function()
  local test_data = {
    {
      name = "/foo/bar/baz/quux.txt",
      modified = false,
      type = "",
      current = false,
      in_window = true,
      expected_label = "1 foo/bar/baz/quux.txt",
    },
    {
      name = "/foo/bar/garply/quux.txt",
      modified = false,
      type = "",
      current = true,
      in_window = true,
      expected_label = "2 foo/bar/garply/quux.txt",
    },
    {
      name = "/garply/bar/baz/quux.txt",
      modified = false,
      type = "",
      current = false,
      in_window = true,
      expected_label = "3 garply/bar/baz/quux.txt",
    },
    {
      name = "/foo/bar/baz/garply.txt",
      modified = false,
      type = "",
      current = false,
      in_window = true,
      expected_label = "4 garply.txt",
    },
    {
      name = "nofile-buffer",
      modified = false,
      type = "nofile",
      current = false,
      in_window = true,
      expected_label = "5 nofile-buffer",
    },
    {
      name = "modified-buffer",
      modified = true,
      type = "",
      current = false,
      in_window = true,
      expected_label = "+6 modified-buffer",
    },
    {
      name = "hidden-buffer",
      modified = true,
      type = "",
      current = false,
      in_window = false,
      expected_label = "+7 hidden-buffer",
    },
    {
      name = "/ends/with/slash/",
      modified = false,
      type = "",
      current = false,
      in_window = false,
      expected_label = "8 /ends/with/slash/",
    },
    {
      name = "/also/ends/with/slash/",
      modified = false,
      type = "",
      current = false,
      in_window = false,
      expected_label = "9 also/ends/with/slash/",
    },
    {
      name = "",
      modified = false,
      type = "nofile",
      current = false,
      in_window = true,
      expected_label = "10 [No name]",
    },
    {
      name = "",
      modified = true,
      type = "",
      current = false,
      in_window = true,
      expected_label = "+11 [No name]",
    },
  }

  describe("get_tabs", function()
    local bo
    local nvim_buf_get_name
    local nvim_get_current_buf
    local user_buffers

    before_each(function()
      bo = vim.bo
      vim.bo = test_data
      nvim_buf_get_name = stub(vim.api, "nvim_buf_get_name").invokes(
        function(buf)
          return test_data[buf].name
        end
      )
      nvim_get_current_buf = stub(vim.api, "nvim_get_current_buf").returns(2)
      user_buffers =
        stub(tabline, "user_buffers").returns(vim.tbl_keys(test_data))
    end)

    after_each(function()
      vim.bo = bo
      nvim_buf_get_name:revert()
      nvim_get_current_buf:revert()
      user_buffers:revert()
    end)

    it("disambiguates labels", function()
      vim.iter(tabline.get_tabs()):enumerate():each(function(i, tab)
        assert.equals(test_data[i].expected_label, tab.label)
      end)
    end)

    it("sorts tabs by buffer number", function()
      vim.iter(tabline.get_tabs()):enumerate():each(function(i, tab)
        assert.equals(i, tab.buf)
      end)
    end)

    it("only marks one tab as current", function()
      local current_tabs = vim.tbl_filter(function(tab)
        return tab.current
      end, tabline.get_tabs())
      assert.equals(1, #current_tabs)
    end)
  end)

  describe("highlight_for", function()
    it("current tab", function()
      assert.equals("TabLineSel", tabline.highlight_for({ current = true }))
    end)

    it("active tab", function()
      assert.equals(
        "TabLineActive",
        tabline.highlight_for({ in_window = true })
      )
    end)

    it("hidden tab", function()
      assert.equals("TabLine", tabline.highlight_for({}))
    end)
  end)

  describe("render", function()
    local bo
    local buf_in_window
    local columns
    local nvim_buf_get_name
    local nvim_get_current_buf
    local user_buffers

    before_each(function()
      bo = vim.bo
      vim.bo = test_data
      buf_in_window = stub(tabline, "buf_in_window").invokes(function(buf)
        return test_data[buf].in_window
      end)
      columns = vim.o.columns
      nvim_buf_get_name = stub(vim.api, "nvim_buf_get_name").invokes(
        function(buf)
          return test_data[buf].name
        end
      )
      nvim_get_current_buf = stub(vim.api, "nvim_get_current_buf").returns(2)
      user_buffers =
        stub(tabline, "user_buffers").returns(vim.tbl_keys(test_data))
    end)

    after_each(function()
      vim.bo = bo
      buf_in_window:revert()
      vim.o.columns = columns
      nvim_buf_get_name:revert()
      nvim_get_current_buf:revert()
      user_buffers:revert()
    end)

    ---@param s string
    ---@return string
    local function strip_highlights(s)
      local ret, _ = s:gsub("%%#%w+#", "")
      return ret
    end

    it("displays all tabs if there is room", function()
      local expected = " "
        .. vim
          .iter(test_data)
          :map(function(tab)
            return tab.expected_label
          end)
          :join("  ")
        .. " "
      vim.o.columns = #expected + 20
      assert.equals(expected, strip_highlights(tabline.render()))
    end)

    it("trims right side to fit", function()
      local expected =
        " 1 foo/bar/baz/quux.txt  2 foo/bar/garply/quux.txt  3 garply/bar/baz/quux.txt>"
      vim.o.columns = #expected
      assert.equals(expected, strip_highlights(tabline.render()))
    end)

    it("trims both sides to fit", function()
      local expected = "</quux.txt  2 foo/bar/garply/quux.txt  3 garply/>"
      vim.o.columns = #expected
      assert.equals(expected, strip_highlights(tabline.render()))
    end)

    it("highlights correctly", function()
      local expected = table.concat({
        "%#TabLineActive# 1 foo/bar/baz/quux.txt ",
        "%#TabLineSel# 2 foo/bar/garply/quux.txt ",
        "%#TabLineActive# 3 garply/bar/baz/quux.txt ",
        "%#TabLineActive# 4 garply.txt ",
        "%#TabLineActive# 5 nofile-buffer ",
        "%#TabLineActive# +6 modified-buffer ",
        "%#TabLine# +7 hidden-buffer ",
        "%#TabLine# 8 /ends/with/slash/ ",
        "%#TabLine# 9 also/ends/with/slash/ ",
        "%#TabLineActive# 10 [No name] ",
        "%#TabLineActive# +11 [No name] ",
        "%#TabLineFill#",
      }, "")
      vim.o.columns = #expected
      assert.equals(expected, tabline.render())
    end)
  end)
end)
