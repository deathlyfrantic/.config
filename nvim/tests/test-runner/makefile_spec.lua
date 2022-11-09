local stub = require("luassert.stub")
local makefile = require("z.test-runner.makefile")

describe("test-runner/makefile", function()
  local findfile, ioopen

  before_each(function()
    findfile = stub(vim.fn, "findfile")
    ioopen = stub(io, "open")
  end)

  after_each(function()
    findfile:revert()
    ioopen:revert()
  end)

  it("returns nil if Makefile is not found", function()
    findfile.returns("")
    assert.is_nil(makefile.test())
  end)

  it("returns nil if Makefile doesn't have a `test` target", function()
    findfile.returns("/foobar/Makefile")
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
    findfile.returns("/foobar/Makefile")
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
