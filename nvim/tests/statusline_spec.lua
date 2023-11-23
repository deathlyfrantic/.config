local stub = require("luassert.stub")
local statusline = require("statusline")

describe("statusline", function()
  describe("filename", function()
    after_each(function()
      vim.api.nvim_buf_set_name(0, "")
    end)

    it("returns filename with tilde", function()
      vim.api.nvim_buf_set_name(0, vim.loop.os_homedir() .. "/foo/bar/baz.txt")
      assert.equals(statusline.filename(), "~/foo/bar/baz.txt")
    end)

    it("returns cwd if buffer name is empty", function()
      assert.equals(
        statusline.filename(),
        "cwd: " .. vim.loop.cwd():gsub(vim.loop.os_homedir(), "~")
      )
    end)
  end)

  describe("gitsigns_status", function()
    it("returns empty string if there is no status", function()
      assert.equals(statusline.gitsigns_status(nil), "")
    end)

    it("returns empty string if status.head is nil", function()
      assert.equals(statusline.gitsigns_status({}), "")
    end)

    it("returns empty string if status.head is empty string", function()
      assert.equals(statusline.gitsigns_status({ head = "" }), "")
    end)

    it("returns status.head if no modifications", function()
      assert.equals(statusline.gitsigns_status({ head = "main" }), "main")
    end)

    it("does not include 0 value modifications in status", function()
      assert.equals(
        statusline.gitsigns_status({
          head = "main",
          added = 1,
          changed = 0,
          removed = 0,
        }),
        "main/+1"
      )
    end)

    it("includes all changes in order if non-zero", function()
      assert.equals(
        statusline.gitsigns_status({
          head = "main",
          added = 1,
          changed = 2,
          removed = 3,
        }),
        "main/+1~2-3"
      )
    end)
  end)

  describe("diagnostics", function()
    local diagnostic_get
    -- these are copied from `statusline.lua`. `diagnostics()` includes
    -- highlighting, so it has to construct the separator and formatting itself.
    local separator = "%1*│%*"
    local error_block = "%2*■%*"
    local warning_block = "%3*■%*"

    local warning = { severity = vim.diagnostic.severity.WARN }
    local error = { severity = vim.diagnostic.severity.ERROR }

    before_each(function()
      diagnostic_get = stub(vim.diagnostic, "get")
    end)

    after_each(function()
      diagnostic_get:revert()
    end)

    it("returns empty string if there are no diagnostics", function()
      diagnostic_get.returns({})
      assert.equals(statusline.diagnostics(), "")
    end)

    it("returns just error count if there are no warnings", function()
      diagnostic_get
        .on_call_with(0, { severity = vim.diagnostic.severity.WARN })
        .returns({})
        .on_call_with(0, { severity = vim.diagnostic.severity.ERROR })
        .returns({ error })
      assert.equals(
        statusline.diagnostics(),
        (" %s %s 1"):format(separator, error_block)
      )
    end)

    it("returns just warning count if there are no errors", function()
      diagnostic_get
        .on_call_with(0, { severity = vim.diagnostic.severity.WARN })
        .returns({ warning, warning })
        .on_call_with(0, { severity = vim.diagnostic.severity.ERROR })
        .returns({})
      assert.equals(
        statusline.diagnostics(),
        (" %s %s 2"):format(separator, warning_block)
      )
    end)

    it("returns errors and warnings if both are non-zero", function()
      diagnostic_get
        .on_call_with(0, { severity = vim.diagnostic.severity.WARN })
        .returns({ warning, warning })
        .on_call_with(0, { severity = vim.diagnostic.severity.ERROR })
        .returns({ error })
      assert.equals(
        statusline.diagnostics(),
        (" %s %s 1 %s 2"):format(separator, error_block, warning_block)
      )
    end)
  end)

  describe("treesitter", function()
    local get_node

    before_each(function()
      get_node = stub(vim.treesitter, "get_node")
    end)

    after_each(function()
      get_node:revert()
    end)

    it("returns empty string if get_node() returns an error", function()
      get_node.invokes(function()
        error("error")
      end)
      assert.equals(statusline.treesitter(), "")
    end)

    it("returns empty string if get_node() returns a falsey value", function()
      get_node.returns(nil)
      assert.equals(statusline.treesitter(), "")
    end)

    it("returns node:type() if get_node() returns a node", function()
      get_node.returns({
        type = function()
          return "node type"
        end,
      })
      assert.equals(statusline.treesitter(), "node type")
    end)
  end)

  describe("init", function()
    before_each(function()
      for _, num in ipairs({ 1, 2, 3 }) do
        vim.api.nvim_set_hl(0, ("User%s"):format(num), {})
      end
    end)

    it("resets highlights when colorscheme changes", function()
      -- assert highlights are empty
      for _, num in ipairs({ 1, 2, 3 }) do
        assert.same(
          vim.api.nvim_get_hl(0, { name = ("User%s"):format(num) }),
          {}
        )
      end
      -- change colorscheme
      vim.cmd.colorscheme("copper")
      -- assert highlights are _not_ empty
      for _, num in ipairs({ 1, 2, 3 }) do
        assert.not_same(
          vim.api.nvim_get_hl(0, { name = ("User%s"):format(num) }),
          {}
        )
      end
    end)
  end)
end)
