local statusline = require("z.statusline")

describe("statusline", function()
  describe("filename", function()
    after_each(function()
      vim.api.nvim_buf_set_name(0, "")
    end)

    it("returns filename with tilde", function()
      vim.api.nvim_buf_set_name(0, vim.fs.normalize("$HOME/foo/bar/baz.txt"))
      assert.equals(statusline.filename(), "~/foo/bar/baz.txt")
    end)

    it("returns cwd if buffer name is empty", function()
      assert.equals(
        statusline.filename(),
        "[cwd: " .. vim.loop.cwd():gsub(vim.fs.normalize("$HOME"), "~") .. "]"
      )
    end)
  end)
end)
