local stub = require("luassert.stub")

describe("source local vimrc", function()
  -- load plugin before running tests
  vim.cmd.source(
    vim.fs.joinpath(vim.fn.stdpath("config"), "plugin", "local-vimrc.lua")
  )

  local source, find

  before_each(function()
    source = stub(vim.cmd, "source")
    find = stub(vim.fs, "find").returns({})
  end)

  after_each(function()
    source:revert()
    find:revert()
    vim.api.nvim_buf_set_name(0, "")
    vim.bo.buftype = ""
  end)

  it("does nothing in a fugitive buffer", function()
    vim.bo.buftype = ""
    vim.api.nvim_exec_autocmds(
      "BufNewfile",
      { group = "local-vimrc", pattern = "fugitive://foobar" }
    )
    assert.stub(find).not_called()
    assert.stub(source).not_called()
  end)

  it("does nothing in help/nofile buffers", function()
    for _, buftype in ipairs({ "help", "nofile" }) do
      vim.bo.buftype = buftype
      vim.api.nvim_exec_autocmds(
        "BufNewfile",
        { group = "local-vimrc", pattern = "*" }
      )
      assert.stub(find).not_called()
      assert.stub(source).not_called()
    end
  end)

  it("forces sourcing for VimEnter event", function()
    vim.bo.buftype = "help"
    vim.api.nvim_exec_autocmds(
      "VimEnter",
      { group = "local-vimrc", pattern = "*" }
    )
    assert.stub(find).called()
  end)

  it("sources files in reverse order", function()
    find.returns({
      "/foo/bar/baz/.vimrc.lua",
      "/foo/bar/.vimrc.lua",
      "/foo/.vimrc.lua",
    })
    vim.api.nvim_exec_autocmds("BufReadPost", {
      group = "local-vimrc",
      pattern = "/foo/bar/baz/quux.txt",
    })
    assert.stub(find).called(1)
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
end)
