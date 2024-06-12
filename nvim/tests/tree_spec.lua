local tree = require("tree")
local stub = require("luassert.stub")

describe("tree", function()
  local data = ([[
    toplevel-foo-1.txt
    toplevel-foo-2.txt
    emptydir/
    bar/bar.txt
    baz/quux/foo.txt
    baz/quux/bar.txt
    garply/foo/bar/baz/quux.txt
    garply/bar/foo/baz/quux.txt]]):dedent()

  it("create_data_structure", function()
    local expected = {
      "toplevel-foo-1.txt",
      "toplevel-foo-2.txt",
      emptydir = {},
      bar = { "bar.txt" },
      baz = { quux = { "foo.txt", "bar.txt" } },
      garply = {
        foo = { bar = { baz = { "quux.txt" } } },
        bar = { foo = { baz = { "quux.txt" } } },
      },
    }
    assert.same(expected, tree.create_data_structure(data:split("\n")))
  end)

  it("format", function()
    local expected = ([[
      bar/
        bar.txt
      baz/
        quux/
          bar.txt
          foo.txt
      emptydir/
      garply/
        bar/
          foo/
            baz/
              quux.txt
        foo/
          bar/
            baz/
              quux.txt
      toplevel-foo-1.txt
      toplevel-foo-2.txt]]):dedent()
    assert.equal(
      expected,
      table.concat(
        tree.format(tree.create_data_structure(data:split("\n"))),
        "\n"
      )
    )
  end)

  describe("find_full_path", function()
    local text = ([[
      foo/
        bar/
          baz.txt
          foobar.txt
        baz/
          waldo.txt
      quux/
        garply/
          waldo.txt
          barbaz.txt
    ]]):dedent():split("\n")
    local nvim_buf_get_lines, nvim_win_get_cursor, tree_dir

    before_each(function()
      nvim_win_get_cursor = stub(vim.api, "nvim_win_get_cursor")
      nvim_buf_get_lines = stub(vim.api, "nvim_buf_get_lines")
      nvim_buf_get_lines.returns(text)
      tree_dir = vim.b.tree_dir
      vim.b.tree_dir = "base_dir/"
    end)

    it("returns nested paths", function()
      local test_cases = {
        "base_dir/foo/",
        "base_dir/foo/bar/",
        "base_dir/foo/bar/baz.txt",
        "base_dir/foo/bar/foobar.txt",
        "base_dir/foo/baz/",
        "base_dir/foo/baz/waldo.txt",
        "base_dir/quux/",
        "base_dir/quux/garply/",
        "base_dir/quux/garply/waldo.txt",
        "base_dir/quux/garply/barbaz.txt",
      }
      for i, expected in ipairs(test_cases) do
        nvim_win_get_cursor.returns({ i, 0 })
        assert.equal(tree.find_full_path(), expected)
      end
    end)

    after_each(function()
      nvim_win_get_cursor:revert()
      nvim_buf_get_lines:revert()
      vim.b.tree_dir = tree_dir
    end)
  end)
end)
