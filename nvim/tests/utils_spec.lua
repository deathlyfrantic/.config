local utils = require("utils")
local spy = require("luassert.spy")
local stub = require("luassert.stub")
local match = require("luassert.match")
local test_utils = require("test-utils")

describe("utils", function()
  describe("tbl_any", function()
    local spied = spy(function(v)
      return v
    end)

    after_each(function()
      spied:clear()
    end)

    it("returns true if any value is true", function()
      local t = { false, false, true, false }
      assert.is_true(utils.tbl_any(spied, t))
      assert.spy(spied).called(3)
    end)

    it("returns false if no value is true", function()
      assert.is_false(utils.tbl_any(spied, { false, false, false }))
      assert.spy(spied).called(3)
    end)
  end)

  describe("tbl_all", function()
    local spied = spy(function(v)
      return v
    end)

    after_each(function()
      spied:clear()
    end)

    it("returns true if all values are true", function()
      assert.is_true(utils.tbl_all(spied, { true, true, true }))
      assert.spy(spied).called(3)
    end)

    it("returns false if any value is not true", function()
      local t = { true, false, true }
      assert.is_false(utils.tbl_all(spied, t))
      assert.spy(spied).called(2)
    end)
  end)

  describe("tbl_find", function()
    local spied = spy(function(v)
      return v % 2 == 0
    end)

    after_each(function()
      spied:clear()
    end)

    it("returns value and index if found", function()
      local value, index = utils.tbl_find(spied, { 1, 3, 5, 7, 8, 9 })
      assert.equals(value, 8)
      assert.equals(index, 5)
      assert.spy(spied).called(5)
    end)

    it("returns first value and index found", function()
      local value, index = utils.tbl_find(spied, { 1, 2, 2, 2, 2 })
      assert.equals(value, 2)
      assert.equals(index, 2)
      assert.spy(spied).called(2)
    end)

    it("returns nil if not found", function()
      local t = { 1, 3, 5, 7, 9 }
      assert.is_nil(utils.tbl_find(spied, t))
      assert.spy(spied).called(#t)
    end)
  end)

  describe("popup", function()
    local function popup(contents, title)
      local win = utils.popup(contents, title)
      local buf = vim.api.nvim_win_get_buf(win)
      local lines = test_utils.get_buf(buf)
      vim.api.nvim_win_close(win, true)
      return { win = win, buf = buf, lines = lines }
    end

    it(
      "works with tables of lines, strings, and uses `tostring` on other types",
      function()
        assert.same(
          popup({ "foo", "bar", "baz" }).lines,
          { "foo", "bar", "baz" }
        )
        assert.same(popup("foo\nbar\nbaz").lines, { "foo", "bar", "baz" })
        assert.same(popup(123).lines, { "123" })
        assert.same(popup(true).lines, { "true" })
        assert.same(popup(nil).lines, { "nil" })
      end
    )

    describe("sets options correctly", function()
      local nvim_open_win, screenrow, screencol

      before_each(function()
        nvim_open_win = spy.on(vim.api, "nvim_open_win")
        screenrow = stub(vim.fn, "screenrow")
        screencol = stub(vim.fn, "screencol")
      end)

      after_each(function()
        nvim_open_win:revert()
        screenrow:revert()
        screencol:revert()
      end)

      local function opts(overrides)
        return vim.tbl_extend("force", {
          relative = "cursor",
          height = 3, -- number of lines
          style = "minimal",
          focusable = false,
          width = 6, -- length of "foobar"
          border = "solid",
        }, overrides or {})
      end

      it("sets title and title_pos if title is provided", function()
        screenrow.returns(1)
        screencol.returns(1)
        local buf = popup({ "foobar", "baz", "quux" }, "title").buf
        assert.spy(nvim_open_win).called_with(
          buf,
          false,
          opts({
            anchor = "NW",
            row = 1,
            col = 1,
            title = "title",
            title_pos = "center",
          })
        )
      end)

      it("opens to northwest", function()
        screenrow.returns(1)
        screencol.returns(1)
        local buf = popup({ "foobar", "baz", "quux" }).buf
        assert
          .spy(nvim_open_win)
          .called_with(buf, false, opts({ anchor = "NW", row = 1, col = 1 }))
      end)

      it("opens to southwest", function()
        screenrow.returns(math.floor((vim.o.lines / 2) + 1))
        screencol.returns(1)
        local buf = popup({ "foobar", "baz", "quux" }).buf
        assert
          .spy(nvim_open_win)
          .called_with(buf, false, opts({ anchor = "SW", row = 0, col = 1 }))
      end)

      it("opens to southeast", function()
        screenrow.returns(math.floor((vim.o.lines / 2) + 1))
        screencol.returns(math.floor((vim.o.columns / 2) + 1))
        local buf = popup({ "foobar", "baz", "quux" }).buf
        assert
          .spy(nvim_open_win)
          .called_with(buf, false, opts({ anchor = "SE", row = 0, col = 0 }))
      end)

      it("opens to northeast", function()
        screenrow.returns(1)
        screencol.returns((math.floor((vim.o.columns / 2) + 1)))
        local buf = popup({ "foobar", "baz", "quux" }).buf
        assert
          .spy(nvim_open_win)
          .called_with(buf, false, opts({ anchor = "NE", col = 0, row = 1 }))
      end)
    end)
  end)

  describe("collect", function()
    it("works on one-argument iterators", function()
      local i = 0
      local iter = function()
        if i < 5 then
          i = i + 1
          return i
        end
      end
      assert.same(utils.collect(iter), { 1, 2, 3, 4, 5 })
    end)

    it("works on three-argument iterators", function()
      assert.same(
        { "/foo/bar/baz/quux", "/foo/bar/baz", "/foo/bar", "/foo", "/" },
        utils.collect(vim.fs.parents("/foo/bar/baz/quux/garply"))
      )
    end)
  end)

  describe("get_hex_color", function()
    local group, fg, bg = "Foobar", "#ff0000", "#0000ff"
    local nvim_get_hl

    before_each(function()
      vim.api.nvim_set_hl(0, group, { fg = fg, bg = bg })
      vim.api.nvim_set_hl(0, "Link1", { link = group })
      vim.api.nvim_set_hl(0, "Link2", { link = "Link1" })
      vim.api.nvim_set_hl(0, "Link3", { link = "Link2" })
      nvim_get_hl = spy.on(vim.api, "nvim_get_hl")
    end)

    after_each(function()
      vim.api.nvim_set_hl(0, group, {})
      for i = 1, 3 do
        vim.api.nvim_set_hl(0, "Link" .. i, {})
      end
      nvim_get_hl:clear()
    end)

    it('returns foreground for "fg" or "foreground"', function()
      assert.equals(utils.get_hex_color(group, "fg"), fg)
      assert.equals(utils.get_hex_color(group, "foreground"), fg)
    end)

    it("returns background for anything else", function()
      assert.equals(utils.get_hex_color(group, "bg"), bg)
      assert.equals(utils.get_hex_color(group, "background"), bg)
      assert.equals(utils.get_hex_color(group, "foobar"), bg)
    end)

    it("follows links", function()
      local result = utils.get_hex_color("Link3", "fg")
      assert.equals(result, fg)
      assert.spy(nvim_get_hl).called(4)
    end)
  end)

  describe("find_project_dir", function()
    local root, cwd
    local homedir = vim.loop.os_homedir()

    before_each(function()
      root = stub(vim.fs, "root")
      cwd = stub(vim.loop, "cwd")
    end)

    after_each(function()
      root:revert()
      cwd:revert()
      vim.b.z_project_dir = nil -- break cache
    end)

    it("should find project directory higher than cwd", function()
      root.returns(homedir .. "/foo")
      cwd.returns(homedir .. "/")
      assert.equals(
        utils.find_project_dir(homedir .. "/foo/bar/baz"),
        homedir .. "/foo/"
      )
    end)

    it("should find project directory lower than cwd", function()
      root.returns(homedir .. "/foo")
      cwd.returns(homedir .. "/foo/bar")
      assert.equals(
        utils.find_project_dir(homedir .. "/foo/bar/baz"),
        homedir .. "/foo/"
      )
    end)

    it("should return cwd if we hit $HOME", function()
      root.returns(nil)
      cwd.returns(homedir .. "/foo")
      assert.equals(
        utils.find_project_dir(homedir .. "/foo/bar/baz"),
        homedir .. "/foo/"
      )
    end)

    it("should return cwd if we hit /", function()
      root.returns(nil)
      cwd.returns(homedir .. "/foo")
      assert.equals(
        utils.find_project_dir("/etc/foo/bar/baz"),
        homedir .. "/foo/"
      )
    end)

    it("should cache result", function()
      root.returns(nil)
      cwd.returns(homedir .. "/foo")
      assert.equals(
        utils.find_project_dir(homedir .. "/foo/bar/baz"),
        homedir .. "/foo/"
      )
      assert.stub(cwd).called(1)
      cwd:clear()
      assert.equals(
        utils.find_project_dir(homedir .. "/foo/bar/baz"),
        homedir .. "/foo/"
      )
      assert.stub(cwd).not_called()
    end)

    it("should use cwd if bufname is empty", function()
      root.returns(nil)
      cwd.returns(homedir .. "/foo")
      local nvim_buf_get_name = stub(vim.api, "nvim_buf_get_name")
      nvim_buf_get_name.returns("")
      utils.find_project_dir()
      assert.stub(root).called_with(vim.loop.cwd(), match._)
      nvim_buf_get_name:revert()
    end)
  end)

  describe("buf_is_real", function()
    local nvim_buf_is_valid, nvim_buf_is_loaded
    local bo = vim.bo

    before_each(function()
      nvim_buf_is_valid = stub(vim.api, "nvim_buf_is_valid")
      nvim_buf_is_loaded = stub(vim.api, "nvim_buf_is_loaded")
    end)

    after_each(function()
      nvim_buf_is_valid:revert()
      nvim_buf_is_loaded:revert()
      vim.bo = bo
    end)

    it("checks buf_is_valid", function()
      nvim_buf_is_valid.returns(false)
      assert.is_false(utils.buf_is_real(1))
      assert.stub(nvim_buf_is_valid).called_with(1)
    end)

    it("checks buf_is_loaded", function()
      nvim_buf_is_valid.returns(true)
      nvim_buf_is_loaded.returns(false)
      assert.is_false(utils.buf_is_real(1))
      assert.stub(nvim_buf_is_valid).called_with(1)
      assert.stub(nvim_buf_is_loaded).called_with(1)
    end)

    it("checks bo[b].buflisted", function()
      nvim_buf_is_valid.returns(true)
      nvim_buf_is_loaded.returns(true)
      vim.bo = { { buflisted = false } }
      assert.is_false(utils.buf_is_real(1))
      assert.stub(nvim_buf_is_valid).called_with(1)
      assert.stub(nvim_buf_is_loaded).called_with(1)
    end)

    it("returns true when all are true", function()
      nvim_buf_is_valid.returns(true)
      nvim_buf_is_loaded.returns(true)
      vim.bo = { { buflisted = true } }
      assert.is_true(utils.buf_is_real(1))
      assert.stub(nvim_buf_is_valid).called_with(1)
      assert.stub(nvim_buf_is_loaded).called_with(1)
    end)
  end)

  describe("char_before_cursor", function()
    local s = "foobar"

    before_each(function()
      test_utils.set_buf(s)
    end)

    after_each(test_utils.clear_buf)

    it("returns correct values", function()
      -- can't set cursor to 6 to check against "r" because there is no trailing
      -- space and the position is clamped; cursor position { 1, 6 } is the same
      -- as position { 1, 5 }
      for i = 1, #s - 1 do
        test_utils.set_cursor(1, i)
        assert.equals(utils.char_before_cursor(), s:sub(i, i))
      end
    end)

    it('returns "" if in the first column', function()
      test_utils.set_cursor(1)
      assert.equals(utils.char_before_cursor(), "")
    end)
  end)

  describe("highlight_at_pos_contains", function()
    local get_node

    before_each(function()
      get_node = spy.on(vim.treesitter, "get_node")
      vim.bo.filetype = "lua"
      test_utils.set_buf([[local s = "foobar"]])
    end)

    after_each(function()
      get_node:revert()
      test_utils.clear_buf()
      test_utils.clear_filetype()
    end)

    it("uses treesitter highlighting if it is enabled", function()
      vim.treesitter.start()
      assert.is_truthy(utils.highlight_at_pos_contains("string", { 1, 12 }))
      assert.is_falsy(utils.highlight_at_pos_contains("string", { 1, 1 }))
      assert.spy(get_node).called_with({ bufnr = 0, pos = { 0, 11 } })
    end)

    it("uses vim regex if treesitter highlighting is not enabled", function()
      local synstack = spy.on(vim.fn, "synstack")
      vim.bo.syntax = ""
      vim.treesitter.stop()
      assert.is_truthy(utils.highlight_at_pos_contains("string", { 1, 12 }))
      assert.is_falsy(utils.highlight_at_pos_contains("string", { 1, 1 }))
      assert.spy(synstack).called_with(1, 12)
      synstack:revert()
    end)

    it("uses cursor position if none is supplied", function()
      local nvim_win_get_cursor = spy.on(vim.api, "nvim_win_get_cursor")
      vim.treesitter.start()
      test_utils.set_cursor(1, 13)
      assert.is_truthy(utils.highlight_at_pos_contains("string"))
      assert.spy(get_node).called_with({ bufnr = 0, pos = { 0, 11 } })
      assert.spy(nvim_win_get_cursor).called_with(0)
      nvim_win_get_cursor:revert()
    end)
  end)

  describe("help", function()
    after_each(function()
      for _, id in ipairs(vim.api.nvim_list_wins()) do
        if vim.bo[vim.api.nvim_win_get_buf(id)].buftype == "help" then
          vim.api.nvim_win_close(id, true)
        end
      end
    end)

    it("opens new window if necessary", function()
      local current_win = vim.api.nvim_get_current_win()
      assert.equals(1, #vim.api.nvim_list_wins())
      utils.help({ "foobar" })
      assert.equals("foobar", vim.api.nvim_get_current_line())
      assert.equals(2, #vim.api.nvim_list_wins())
      assert.not_equal(current_win, vim.api.nvim_get_current_win())
      local buf = vim.api.nvim_get_current_buf()
      assert.equals("help", vim.bo[buf].buftype)
      assert.equals("help", vim.bo[buf].filetype)
      assert.is_true(vim.bo[buf].readonly)
      assert.is_false(vim.bo[buf].modified)
      assert.is_false(vim.bo[buf].modifiable)
    end)

    it("uses open help window if there is one", function()
      vim.cmd("silent! help")
      local help_win = vim.api.nvim_get_current_win()
      local help_buf = vim.api.nvim_get_current_buf()
      assert.not_equal("foobar", vim.api.nvim_get_current_line())
      utils.help({ "foobar" })
      assert.equals(help_win, vim.api.nvim_get_current_win())
      assert.not_equal(help_buf, vim.api.nvim_get_current_buf())
      assert.equals("foobar", vim.api.nvim_get_current_line())
    end)

    it("splits a string on newlines", function()
      utils.help("foo\nbar\nbaz")
      assert.same({ "foo", "bar", "baz" }, test_utils.get_buf())
    end)

    it("reduces window height if contents are smaller than window", function()
      vim.cmd("silent! help")
      assert.not_equal(1, vim.api.nvim_win_get_height(0))
      utils.help("foobar")
      assert.equals(1, vim.api.nvim_win_get_height(0))
    end)
  end)

  describe("v_star_search_set", function()
    local getreg, setreg

    before_each(function()
      getreg = stub(vim.fn, "getreg")
      setreg = stub(vim.fn, "setreg")
    end)

    after_each(function()
      getreg:revert()
      setreg:revert()
    end)

    it("works with all patterns", function()
      -- test patterns from
      -- https://github.com/bronson/vim-visual-star-search/blob/master/test-patterns
      local test_patterns = {
        ["don't"] = "don't",
        ["'don't'"] = "'don't'",
        ["'don''t'"] = "'don''t'",
        ['"amy\'s quote"'] = [["amy's quote"]],
        ["{,*/}"] = [[{,\*\/}]],
        ["**"] = [[\*\*]],
        ["a[bc]d"] = [[a\[bc]d]],
        ["g~re"] = [[g\~re]],
        ["hello."] = [[hello\.]],
        ["helloo"] = "helloo",
        ["foo^^^bar"] = [[foo\^\^\^bar]],
        ["vv"] = [[v\%x16v]],
      }
      for test, expected in pairs(test_patterns) do
        getreg.returns(test)
        utils.v_star_search_set("/")
        assert.stub(setreg).called_with("/", expected)
        setreg:clear()
      end
    end)

    it([[doesn't escape \ and * when raw is true]], function()
      local escape = stub(vim.fn, "escape")
      getreg.returns("foobar")
      utils.v_star_search_set("/", true)
      assert.stub(escape).not_called()
      escape:revert()
    end)

    it("works with ?", function()
      getreg.returns("foo?bar")
      utils.v_star_search_set("?")
      assert.stub(setreg).called_with("/", [[foo\?bar]])
    end)
  end)

  describe("make_operator_fn", function()
    local normal, getreg, notify
    local spied = spy(function(v)
      return v
    end)
    local default_error_msg =
      "Multiline selections do not work with this operator"

    before_each(function()
      normal = stub(vim.cmd, "normal")
      getreg = stub(vim.fn, "getreg")
      notify = stub(vim, "notify")
    end)

    after_each(function()
      normal:revert()
      getreg:revert()
      notify:revert()
      spied:clear()
    end)

    it("returns a function", function()
      assert.equals(type(utils.make_operator_fn(spied)), "function")
    end)

    it("does not work with visual linewise selections", function()
      local operator = utils.make_operator_fn(spied)
      operator("V")
      assert.stub(notify).called_with(default_error_msg, vim.log.levels.ERROR)
      assert.spy(spied).not_called()
    end)

    it("does not work with visual blockwise selections", function()
      local operator = utils.make_operator_fn(spied)
      operator("")
      assert.stub(notify).called_with(default_error_msg, vim.log.levels.ERROR)
      assert.spy(spied).not_called()
    end)

    it("yanks area if mode is visual", function()
      getreg.returns("selection")
      local operator = utils.make_operator_fn(spied)
      operator("v")
      assert.stub(notify).not_called()
      assert
        .stub(normal)
        .called_with({ args = { "y" }, bang = true, mods = { silent = true } })
      assert.spy(spied).called(1)
      assert.spy(spied).called_with("selection")
    end)

    it("yanks last-selected visual area if mode is not visual", function()
      getreg.returns("selection")
      local operator = utils.make_operator_fn(spied)
      operator("n")
      assert.stub(notify).not_called()
      assert.stub(normal).called_with({
        args = { "`[v`]y" },
        bang = true,
        mods = { silent = true },
      })
      assert.spy(spied).called(1)
      assert.spy(spied).called_with("selection")
    end)

    it("does not work if selection is an empty string", function()
      -- not clear to me this can even happen
      getreg.returns("")
      local operator = utils.make_operator_fn(spied)
      operator("v")
      assert
        .stub(normal)
        .called_with({ args = { "y" }, bang = true, mods = { silent = true } })
      assert.stub(notify).called_with("No selection", vim.log.levels.ERROR)
      assert.spy(spied).not_called()
    end)

    it("does not work if selection is nil", function()
      -- not clear to me this can even happen
      getreg.returns(nil)
      local operator = utils.make_operator_fn(spied)
      operator("v")
      assert
        .stub(normal)
        .called_with({ args = { "y" }, bang = true, mods = { silent = true } })
      assert.stub(notify).called_with("No selection", vim.log.levels.ERROR)
      assert.spy(spied).not_called()
    end)

    it("does not work if selection contains newlines", function()
      getreg.returns("foo\nbar\nbaz")
      local operator = utils.make_operator_fn(spied)
      operator("v")
      assert
        .stub(normal)
        .called_with({ args = { "y" }, bang = true, mods = { silent = true } })
      assert.stub(notify).called_with(default_error_msg, vim.log.levels.ERROR)
      assert.spy(spied).not_called()
    end)

    it("saves register and selection state", function()
      getreg:revert()
      local regsave = vim.fn.getreg("@")
      local selsave = vim.o.selection
      vim.fn.setreg("@", "this is my selection")
      vim.o.selection = "old"
      local operator = utils.make_operator_fn(spied)
      operator("n")
      assert.stub(notify).not_called()
      assert.stub(normal).called_with({
        args = { "`[v`]y" },
        bang = true,
        mods = { silent = true },
      })
      assert.spy(spied).called(1)
      assert.spy(spied).called_with("this is my selection")
      assert.equals(vim.fn.getreg("@"), "this is my selection")
      assert.equals(vim.o.selection, "old")
      vim.fn.setreg("@", regsave)
      vim.o.selection = selsave
    end)
  end)
end)
