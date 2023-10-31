local utils = require("z.test-runner.utils")

local M = {}

function M.find_nearest_treesitter()
  return utils.find_nearest_test_via_treesitter(
    [[((call_expression
      function: ((identifier) @fn (#any-of? @fn "describe" "it" "test" "context")) 
      arguments: (arguments . (string ((string_fragment) @testname)))))
    ]],
    "testname"
  )
end

function M.find_nearest_regex()
  vim.notify(
    "couldn't find test from treesitter, falling back to regex",
    vim.log.levels.ERROR
  )
  local test = utils.find_nearest_test(
    [[^\s*\(it\|describe\|test\|context\)(["'']\(.*\)["''],]],
    3
  )
  if test ~= nil then
    return vim.fn.substitute(test, [[\([{\[(+)\]}]\)]], [[\\\1]], "g")
  end
  return nil
end

local function find_nearest()
  return M.find_nearest_treesitter() or M.find_nearest_regex()
end

function M.npm_or_yarn()
  if vim.b.z_test_runner_npm_or_yarn == nil then
    if vim.fn.findfile("yarn.lock", ";") ~= "" then
      vim.b.z_test_runner_npm_or_yarn = "yarn"
    else
      vim.b.z_test_runner_npm_or_yarn = "npm"
    end
  end
  return vim.b.z_test_runner_npm_or_yarn
end

function M.mocha(selection, pretest)
  local cmd = "npx mocha -- spec "
    .. vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  if pretest and #pretest > 0 then
    cmd = pretest .. " && " .. cmd
  end
  if selection == "nearest" then
    local nearest = find_nearest()
    if nearest ~= nil then
      return cmd .. " --grep=" .. vim.fn.shellescape(find_nearest())
    end
  elseif selection == "file" then
    return cmd
  end
  return M.npm_or_yarn() .. " test"
end

function M.jest(selection)
  local cmd = M.npm_or_yarn() .. " test"
  if cmd:starts_with("npm") then
    cmd = cmd .. " --"
  end
  if selection == "nearest" then
    local nearest = find_nearest()
    if nearest ~= nil then
      return cmd .. " -t " .. vim.fn.shellescape(find_nearest())
    end
  elseif selection == "file" then
    return cmd .. " " .. vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  end
  return cmd
end

function M.test(selection)
  local package_json = vim.fn.findfile("package.json", ";")
  if package_json == "" then
    return nil
  end
  local package = vim.json.decode(io.open(package_json):read("*all"))
  local scripts = package.scripts or {}
  local test_cmd = scripts.test or ""
  if test_cmd:match("mocha") then
    return M.mocha(selection, scripts.pretest or "")
  elseif test_cmd:match("jest") then
    return M.jest(selection)
  end
  if #test_cmd > 0 then
    return M.npm_or_yarn() .. " test"
  end
end

return M
