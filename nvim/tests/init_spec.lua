local stub = require("luassert.stub")
local utils = require("utils")

describe("init", function()
  describe("quits even if dirvish or quickfix is open", function()
    local bo, quit, nvim_buf_delete, nvim_list_bufs, nvim_list_wins

    before_each(function()
      bo = vim.bo
      quit = stub(vim.cmd, "quit")
      nvim_list_wins = stub(vim.api, "nvim_list_wins").returns({ 1 })
      nvim_list_bufs = stub(vim.api, "nvim_list_bufs")
      nvim_buf_delete = stub(vim.api, "nvim_buf_delete")
    end)

    after_each(function()
      vim.bo = bo
      quit:revert()
      nvim_list_wins:revert()
      nvim_list_bufs:revert()
      nvim_buf_delete:revert()
    end)

    it("quickfix", function()
      vim.bo = { { buflisted = true }, buftype = "quickfix" }
      nvim_list_bufs.returns({})
      vim.api.nvim_exec_autocmds(
        "BufEnter",
        { group = "init-autocmds", pattern = "*" }
      )
      assert.stub(quit).called(1)
      assert.stub(nvim_buf_delete).not_called()
    end)

    it("dirvish", function()
      vim.bo = { { buflisted = true }, filetype = "dirvish" }
      nvim_list_bufs.returns({ 1 })
      vim.api.nvim_exec_autocmds(
        "BufEnter",
        { group = "init-autocmds", pattern = "*" }
      )
      assert.stub(quit).called(1)
      assert.stub(nvim_buf_delete).not_called()
    end)

    it("deletes buffer if conditions not met", function()
      -- there is a reason for the logic that this is testings but i do not
      -- remember what it is
      vim.bo =
        { { buflisted = false }, buftype = "nofile", filetype = "dirvish" }
      nvim_list_bufs.returns({})
      vim.api.nvim_exec_autocmds(
        "BufEnter",
        { group = "init-autocmds", pattern = "*" }
      )
      assert.stub(quit).not_called()
      assert.stub(nvim_buf_delete).called_with(0, { force = true })
    end)
  end)

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

  it("don't move position when switching buffers", function()
    local winrestview = stub(vim.fn, "winrestview")
    local buf = vim.api.nvim_win_get_buf(0)
    assert.is_nil(vim.b[buf].winview)
    vim.api.nvim_exec_autocmds(
      "BufWinLeave",
      { group = "init-autocmds", pattern = "*" }
    )
    assert.is_truthy(vim.b[buf].winview)
    local winview = vim.b[buf].winview
    vim.api.nvim_exec_autocmds(
      "BufWinEnter",
      { group = "init-autocmds", pattern = "*" }
    )
    assert.stub(winrestview).called_with(winview)
    assert.is_nil(vim.b[buf].winview)
    winrestview:revert()
  end)

  it("sets terminal settings", function()
    vim.opt_local.number = true
    vim.opt_local.statusline = ""
    vim.api.nvim_exec_autocmds(
      "TermOpen",
      { group = "init-autocmds", pattern = "*" }
    )
    assert.is_false(vim.opt_local.number:get())
    assert.equals(vim.opt_local.statusline:get(), "[terminal] %{b:term_title}")
    vim.opt_local.statusline = ""
  end)

  describe("config reloading", function()
    local colorscheme, source

    before_each(function()
      colorscheme = stub(vim.cmd, "colorscheme")
      source = stub(vim.cmd, "source")
    end)

    after_each(function()
      colorscheme:revert()
      source:revert()
    end)

    it("reloads $MYVIMRC", function()
      vim.api.nvim_exec_autocmds(
        "BufWritePost",
        { group = "init-autocmds", pattern = vim.env.MYVIMRC }
      )
      assert.stub(source).called_with("$MYVIMRC")
    end)

    it("reloads plugin and lua library files", function()
      for _, f in ipairs({ "/plugin/foo.lua", "/lua/bar.lua" }) do
        vim.api.nvim_exec_autocmds("BufWritePost", {
          group = "init-autocmds",
          pattern = vim.fn.stdpath("config") .. f,
        })
        assert.stub(source).called_with(vim.fn.stdpath("config") .. f)
      end
    end)

    it("doesn't reload non-lua files", function()
      vim.api.nvim_exec_autocmds("BufWritePost", {
        group = "init-autocmds",
        pattern = vim.fn.stdpath("config") .. "/plugin/baz.txt",
      })
      assert.stub(source).not_called()
    end)

    it("refreshes colorscheme on save", function()
      vim.api.nvim_exec_autocmds("BufWritePost", {
        group = "init-autocmds",
        pattern = vim.fn.stdpath("config") .. "/colors/foobar.lua",
      })
      assert.stub(colorscheme).called_with("foobar")
    end)
  end)

  it("close floating windows", function()
    local nvim_list_wins =
      stub(vim.api, "nvim_list_wins").returns({ 1, 2, 3, 4, 5 })
    local nvim_win_get_config = stub(vim.api, "nvim_win_get_config").by_default
      .returns({ relative = "" })
      .on_call_with(2)
      .returns({ relative = "cursor" })
      .on_call_with(4)
      .returns({ relative = "win" })
    local nvim_win_close = stub(vim.api, "nvim_win_close")
    -- it should close all floating windows but not close non-floating windows
    vim.cmd.CloseFloatingWindows()
    assert.stub(nvim_win_close).called(2)
    assert.stub(nvim_win_close).called_with(2, true)
    assert.stub(nvim_win_close).called_with(4, true)
    nvim_list_wins:revert()
    nvim_win_get_config:revert()
    nvim_win_close:revert()
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

    -- this is a hacky way to access the otherwise-hidden callback for a keymap
    -- but it works, and it's easier than trying to use insert mode in a test
    local arrow = utils.tbl_find(function(m)
      return m.lhs == "<C-J>"
    end, vim.api.nvim_get_keymap("i")).callback

    local fat_arrow = utils.tbl_find(function(m)
      return m.lhs == "<C-L>"
    end, vim.api.nvim_get_keymap("i")).callback

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

  describe("quickfix toggle", function()
    local bo, nvim_list_bufs

    before_each(function()
      bo = vim.bo
      nvim_list_bufs = stub(vim.api, "nvim_list_bufs").returns({})
    end)

    after_each(function()
      vim.bo = bo
      nvim_list_bufs:revert()
    end)

    local quickfix_toggle = utils.tbl_find(function(m)
      return m.lhs == "\\q"
    end, vim.api.nvim_get_keymap("n")).callback

    it("closes quickfix window if already open", function()
      vim.bo = { { filetype = "qf", buflisted = true } }
      nvim_list_bufs.returns({ 1 })
      assert.equals(quickfix_toggle(), ":cclose<CR>")
    end)

    it("opens quickfix window vertically", function()
      local height = math.floor(vim.o.columns / 3)
      assert.equals(
        quickfix_toggle(true),
        ":topleft vertical copen " .. height .. "<CR>"
      )
    end)

    it("opens quickfix window horizontally", function()
      assert.equals(quickfix_toggle(), ":botright copen<CR>")
    end)
  end)

  describe("source local vimrc", function()
    local source, findfile

    before_each(function()
      source = stub(vim.cmd, "source")
      findfile = stub(vim.fn, "findfile").returns({})
    end)

    after_each(function()
      source:revert()
      findfile:revert()
      vim.api.nvim_buf_set_name(0, "")
      vim.bo.buftype = ""
    end)

    it("does nothing in a fugitive buffer", function()
      vim.bo.buftype = ""
      vim.api.nvim_exec_autocmds(
        "BufNewfile",
        { group = "init-autocmds-local-vimrc", pattern = "fugitive://foobar" }
      )
      assert.stub(findfile).not_called()
      assert.stub(source).not_called()
    end)

    it("does nothing in help/nofile buffers", function()
      for _, buftype in ipairs({ "help", "nofile" }) do
        vim.bo.buftype = buftype
        vim.api.nvim_exec_autocmds(
          "BufNewfile",
          { group = "init-autocmds-local-vimrc", pattern = "*" }
        )
        assert.stub(findfile).not_called()
        assert.stub(source).not_called()
      end
    end)

    it("forces sourcing for VimEnter event", function()
      vim.bo.buftype = "help"
      vim.api.nvim_exec_autocmds(
        "VimEnter",
        { group = "init-autocmds-local-vimrc", pattern = "*" }
      )
      assert.stub(findfile).called()
    end)

    it("sources files in reverse order", function()
      findfile.returns({
        "/foo/bar/baz/.vimrc.lua",
        "/foo/bar/.vimrc.lua",
        "/foo/.vimrc.lua",
      })
      vim.api.nvim_exec_autocmds("BufReadPost", {
        group = "init-autocmds-local-vimrc",
        pattern = "/foo/bar/baz/quux.txt",
      })
      assert.stub(findfile).called(1)
      assert.stub(source).called(3)
      assert.same(source.calls[1].vals[1], {
        args = { "/foo/.vimrc.lua" },
        mods = { emsg_silent = true, silent = true },
      })
      assert.same(source.calls[2].vals[1], {
        args = { "/foo/bar/.vimrc.lua" },
        mods = { emsg_silent = true, silent = true },
      })
      assert.same(source.calls[3].vals[1], {
        args = { "/foo/bar/baz/.vimrc.lua" },
        mods = { emsg_silent = true, silent = true },
      })
    end)

    it("make non-existent directories before writing file", function()
      local confirm = stub(vim.fn, "confirm").returns(1)
      local fs_stat = stub(vim.loop, "fs_stat").returns(false)
      local mkdir = stub(vim.fn, "mkdir")
      vim.api.nvim_exec_autocmds("BufWritePre", {
        group = "init-autocmds-mkdir-on-write",
        pattern = "/foo/bar/baz.txt",
      })
      assert.stub(mkdir).called_with("/foo/bar", "p")
      confirm:revert()
      fs_stat:revert()
      mkdir:revert()
    end)
  end)
end)
