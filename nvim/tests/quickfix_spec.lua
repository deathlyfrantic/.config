local stub = require("luassert.stub")
local test_utils = require("test-utils")

describe("quickfix toggle", function()
  test_utils.source_plugin("quickfix")

  local bo, cclose, copen, nvim_list_bufs

  before_each(function()
    bo = vim.bo
    cclose = stub(vim.cmd, "cclose")
    copen = stub(vim.cmd, "copen")
    nvim_list_bufs = stub(vim.api, "nvim_list_bufs").returns({})
  end)

  after_each(function()
    vim.bo = bo
    cclose:revert()
    copen:revert()
    nvim_list_bufs:revert()
  end)

  local quickfix_toggle = test_utils.get_keymap_callback("n", "\\q")

  it("closes quickfix window if already open", function()
    vim.bo = { { filetype = "qf", buflisted = true } }
    nvim_list_bufs.returns({ 1 })
    quickfix_toggle()
    assert.stub(cclose).called()
    assert.stub(copen).not_called()
  end)

  it("opens quickfix window vertically", function()
    local height = math.floor(vim.o.columns / 3)
    quickfix_toggle(true)
    assert.stub(cclose).not_called()
    assert.stub(copen).called_with({
      mods = { split = "topleft", vertical = true },
      range = { height },
    })
  end)

  it("opens quickfix window horizontally", function()
    quickfix_toggle()
    assert.stub(cclose).not_called()
    assert.stub(copen).called_with({ mods = { split = "botright" } })
  end)
end)
