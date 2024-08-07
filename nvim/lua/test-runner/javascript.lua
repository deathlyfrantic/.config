local utils = require("test-runner.utils")

local M = {}

---@return string?
function M.find_nearest_treesitter()
  return utils.find_nearest_test_via_treesitter(
    [[((call_expression
      function: ((identifier) @fn (#any-of? @fn "describe" "it" "test" "context")) 
      arguments: (arguments . (string ((string_fragment) @testname)))))
    ]],
    "testname"
  )
end

---@return string?
function M.find_nearest_regex()
  vim.notify(
    "couldn't find test from treesitter, falling back to regex",
    vim.log.levels.ERROR
  )
  local test = utils.find_nearest_test(
    [[^\s*\(it\|describe\|test\|context\)(["'']\(.*\)["''],]],
    3
  )
  if test then
    return vim.fn.substitute(test, [[\([{\[(+)\]}]\)]], [[\\\1]], "g")
  end
  return nil
end

---@return string?
local function find_nearest()
  return M.find_nearest_treesitter() or M.find_nearest_regex()
end

---@return "npm" | "yarn"
function M.npm_or_yarn()
  if not vim.b.z_test_runner_npm_or_yarn then
    local paths = vim.fs.find("yarn.lock", {
      upward = true,
      stop = vim.uv.os_homedir(),
      path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
      type = "file",
    })
    vim.b.z_test_runner_npm_or_yarn = #paths > 0 and "yarn" or "npm"
  end
  return vim.b.z_test_runner_npm_or_yarn
end

---@param selection TestRunnerSelection
---@param pretest string?
---@return string
function M.mocha(selection, pretest)
  local cmd = "npx mocha -- spec "
    .. vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  if pretest and #pretest > 0 then
    cmd = pretest .. " && " .. cmd
  end
  if selection == "nearest" then
    local nearest = find_nearest()
    if nearest then
      return cmd .. " --grep=" .. vim.fn.shellescape(find_nearest())
    end
  elseif selection == "file" then
    return cmd
  end
  return M.npm_or_yarn() .. " test"
end

---@param selection TestRunnerSelection
---@return string
function M.jest(selection)
  local cmd = M.npm_or_yarn() .. " test"
  if cmd:starts_with("npm") then
    cmd = cmd .. " --"
  end
  if selection == "nearest" then
    local nearest = find_nearest()
    if nearest then
      return cmd .. " -t " .. vim.fn.shellescape(find_nearest())
    end
  elseif selection == "file" then
    return cmd .. " " .. vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  end
  return cmd
end

---@param selection TestRunnerSelection
---@return string?
function M.test(selection)
  local paths = vim.fs.find("package.json", {
    upward = true,
    stop = vim.uv.os_homedir(),
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    type = "file",
  })
  if #paths == 0 then
    return nil
  end
  local package = vim.json.decode(io.open(paths[1]):read("*all"))
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
