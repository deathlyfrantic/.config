local stub = require("luassert.stub")
local utils = require("utils")
local test_utils = require("test-utils")

describe("init", function()
  describe("last position jump", function()
    local nvim_buf_line_count, nvim_buf_get_mark, nvim_buf_get_name, nvim_win_set_cursor

    before_each(function()
      nvim_buf_get_mark = stub(vim.api, "nvim_buf_get_mark").returns({ 2, 3 })
      nvim_buf_get_name = stub(vim.api, "nvim_buf_get_name").returns("bufname")
      nvim_buf_line_count = stub(vim.api, "nvim_buf_line_count").returns(10)
      nvim_win_set_cursor = stub(vim.api, "nvim_win_set_cursor")
    end)

    after_each(function()
      nvim_buf_get_mark:revert()
      nvim_buf_get_name:revert()
      nvim_buf_line_count:revert()
      nvim_win_set_cursor:revert()
    end)

    it("sets cursor to previous position in buffer", function()
      vim.api.nvim_exec_autocmds(
        "BufReadPost",
        { group = "init-autocmds", pattern = "*" }
      )
      assert.stub(nvim_win_set_cursor).called_with(0, { 2, 3 })
    end)

    it("doesn't set position if buffer is empty", function()
      nvim_buf_line_count.returns(1)
      vim.api.nvim_exec_autocmds(
        "BufReadPost",
        { group = "init-autocmds", pattern = "*" }
      )
      assert.stub(nvim_win_set_cursor).not_called()
    end)

    it("doesn't set position if mark is somehow invalid", function()
      nvim_buf_get_mark.returns({ -1, -1 })
      vim.api.nvim_exec_autocmds(
        "BufReadPost",
        { group = "init-autocmds", pattern = "*" }
      )
      assert.stub(nvim_win_set_cursor).not_called()
    end)

    it("doesn't set previous position for git commit messages", function()
      nvim_buf_get_name.returns("COMMIT_EDITMSG")
      vim.api.nvim_exec_autocmds(
        "BufReadPost",
        { group = "init-autocmds", pattern = "*" }
      )
      assert.stub(nvim_win_set_cursor).not_called()
    end)
  end)

  it("sets terminal settings", function()
    vim.opt_local.statusline = ""
    vim.api.nvim_exec_autocmds(
      "TermOpen",
      { group = "init-autocmds", pattern = "*" }
    )
    assert.equals(vim.opt_local.statusline:get(), "[terminal] %{b:term_title}")
    vim.opt_local.statusline = ""
  end)

  describe("config reloading", function()
    local source

    before_each(function()
      source = stub(vim.cmd, "source")
    end)

    after_each(function()
      source:revert()
    end)

    it("reloads $MYVIMRC", function()
      vim.api.nvim_exec_autocmds(
        "BufWritePost",
        { group = "init-autocmds", pattern = vim.env.MYVIMRC }
      )
      assert.stub(source).called_with(vim.env.MYVIMRC)
    end)

    it("reloads plugin, lua, and colors library files", function()
      for _, f in ipairs({
        "/plugin/foo.lua",
        "/lua/bar.lua",
        "/colors/baz.lua",
      }) do
        vim.api.nvim_exec_autocmds("BufWritePost", {
          group = "init-autocmds",
          pattern = vim.fs.joinpath(vim.fn.stdpath("config"), f),
        })
        assert
          .stub(source)
          .called_with(vim.fs.joinpath(vim.fn.stdpath("config"), f))
      end
    end)

    it("doesn't reload non-lua files", function()
      vim.api.nvim_exec_autocmds("BufWritePost", {
        group = "init-autocmds",
        pattern = vim.fs.joinpath(
          vim.fn.stdpath("config"),
          "plugin",
          "baz.txt"
        ),
      })
      assert.stub(source).not_called()
    end)
  end)

  describe("Fit command", function()
    local getwininfo, nvim_buf_get_lines, nvim_buf_line_count, nvim_win_set_height, nvim_win_set_width

    before_each(function()
      getwininfo = stub(vim.fn, "getwininfo")
      nvim_buf_get_lines = stub(vim.api, "nvim_buf_get_lines")
      nvim_buf_line_count = stub(vim.api, "nvim_buf_line_count")
      nvim_win_set_height = stub(vim.api, "nvim_win_set_height")
      nvim_win_set_width = stub(vim.api, "nvim_win_set_width")
    end)

    after_each(function()
      getwininfo:revert()
      nvim_buf_get_lines:revert()
      nvim_buf_line_count:revert()
      nvim_win_set_height:revert()
      nvim_win_set_width:revert()
    end)

    it("resizes horizontally without bang", function()
      nvim_buf_get_lines.returns({ "foo", "bar1", "baz23" })
      getwininfo.returns({ { textoff = 2 } })
      vim.cmd.Fit()
      assert.stub(getwininfo).called_with(vim.api.nvim_get_current_win())
      assert.stub(nvim_win_set_width).called_with(0, 5 + 2 + 1)
    end)

    it("resizes vertically with bang", function()
      nvim_buf_line_count.returns(20)
      vim.cmd.Fit({ bang = true })
      assert.stub(nvim_buf_line_count).called_with(0)
      assert.stub(nvim_win_set_height).called_with(0, 20)
    end)
  end)

  describe("arrows", function()
    local char_before_cursor, nvim_get_current_line, nvim_win_get_cursor

    before_each(function()
      char_before_cursor = stub(utils, "char_before_cursor").returns("")
      nvim_get_current_line =
        stub(vim.api, "nvim_get_current_line").returns("foobar")
      nvim_win_get_cursor =
        stub(vim.api, "nvim_win_get_cursor").returns({ 1, 0 })
    end)

    after_each(function()
      char_before_cursor:revert()
      nvim_get_current_line:revert()
      nvim_win_get_cursor:revert()
    end)

    local arrow = test_utils.get_keymap_callback("i", "<C-J>")
    local fat_arrow = test_utils.get_keymap_callback("i", "<C-L>")

    it("doesn't add a space before if in the first column", function()
      assert.equals(arrow(), "-> ")
      assert.equals(fat_arrow(), "=> ")
    end)

    it("doesn't add a space before if there already is one", function()
      char_before_cursor.returns("\t")
      assert.equals(arrow(), "-> ")
      assert.equals(fat_arrow(), "=> ")
    end)

    it(
      "adds space before if immediately preceded by a non-whitespace character",
      function()
        char_before_cursor.returns("r")
        nvim_win_get_cursor.returns({ 1, 6 })
        assert.equals(arrow(), " -> ")
        assert.equals(fat_arrow(), " => ")
      end
    )

    it("moves cursor right if followed by a whitespace character", function()
      char_before_cursor.returns("r")
      nvim_get_current_line.returns("foobar ")
      nvim_win_get_cursor.returns({ 1, 6 })
      assert.equals(arrow(), " -><Right>")
      assert.equals(fat_arrow(), " =><Right>")
    end)
  end)
end)
