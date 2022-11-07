local api = vim.api
local find_nearest_test = require("z.test-runner.utils").find_nearest_test

local function find_nearest_javascript_test_from_treesitter()
  local row, col = unpack(api.nvim_win_get_cursor(0))
  -- treesitter rows are 0-indexed
  local node = vim.treesitter.get_node_at_pos(0, row - 1, col)
  while node do
    if node:type() == "call_expression" then
      local fn = node:field("function")[1]
      local fname = vim.treesitter.query.get_node_text(fn, 0)
      if vim.tbl_contains({ "it", "describe", "test" }, fname) then
        local args = node:field("arguments")[1]
        local first_arg = args:child(1)
        if first_arg:type() == "string" then
          local text = first_arg:child(1)
          if text:type() == "string_fragment" then
            return vim.treesitter.query.get_node_text(text, 0)
          end
        end
      end
    end
    node = node:parent()
  end
end

local function find_nearest_javascript_test()
  local test = find_nearest_javascript_test_from_treesitter()
  if test ~= nil then
    return test
  end
  api.nvim_err_writeln(
    "couldn't find test from treesitter, falling back to regex"
  )
  test = find_nearest_test([[^\s*\(it\|describe\|test\)(["'']\(.*\)["''],]], 3)
  return vim.fn.substitute(test, [[\([{\[(+)\]}]\)]], [[\\\1]], "g")
end

local function npm_or_yarn()
  if vim.fn.findfile("yarn.lock", ";") ~= "" then
    return "yarn"
  end
  return "npm"
end

local function javascript_mocha(selection, pretest)
  local cmd = "npx mocha -- spec " .. vim.fs.normalize(api.nvim_buf_get_name(0))
  if #pretest > 0 then
    cmd = pretest .. " && " .. cmd
  end
  if selection == "nearest" then
    return cmd
      .. " --grep="
      .. vim.fn.shellescape(find_nearest_javascript_test())
  elseif selection == "file" then
    return cmd
  end
  return npm_or_yarn() .. " test"
end

local function javascript_jest(selection)
  local cmd = npm_or_yarn() .. " test"
  if vim.startswith(cmd, "npm") then
    cmd = cmd .. " --"
  end
  if selection == "nearest" then
    return cmd .. " -t " .. vim.fn.shellescape(find_nearest_javascript_test())
  elseif selection == "file" then
    return cmd .. " " .. vim.fs.normalize(api.nvim_buf_get_name(0))
  end
  return cmd
end

local function test(selection)
  local package_json = vim.fn.findfile("package.json", ";")
  if package_json == "" then
    return nil
  end
  local package = vim.json.decode(io.open(package_json):read("*all"))
  local scripts = package.scripts or {}
  local test_cmd = scripts.test or ""
  if test_cmd:match("mocha") then
    return javascript_mocha(selection, scripts.pretest or "")
  elseif test_cmd:match("jest") then
    return javascript_jest(selection)
  end
  if #test_cmd > 0 then
    return npm_or_yarn() .. " test"
  end
end

return { test = test }
