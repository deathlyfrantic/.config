local stub = require("luassert.stub")
local makefile = require("test-runner.makefile")

describe("test-runner/makefile", function()
  local find, ioopen

  before_each(function()
    find = stub(vim.fs, "find")
    ioopen = stub(io, "open")
  end)

  after_each(function()
    find:revert()
    ioopen:revert()
  end)

  it("returns nil if Makefile is not found", function()
    find.returns({})
    assert.is_nil(makefile.test())
  end)

  it("returns nil if Makefile doesn't have a `test` target", function()
    find.returns({ "/foobar/Makefile" })
    ioopen.returns({
      lines = function()
        return function()
          return nil
        end
      end,
    })
    assert.is_nil(makefile.test())
  end)

  it("returns command if Makefile has a `test` target", function()
    find.returns({ "/foobar/Makefile" })
    ioopen.returns({
      lines = function()
        return function()
          return "test:"
        end
      end,
    })
    assert.equals("(cd /foobar && make test)", makefile.test())
  end)
end)
