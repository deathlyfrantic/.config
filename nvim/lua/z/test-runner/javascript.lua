local api = vim.api
local find_nearest_test = require("z.test-runner.utils").find_nearest_test

local function find_nearest_treesitter()
  local query = vim.treesitter.parse_query(
    vim.bo.filetype,
    [[((call_expression
      function: ((identifier) @fn (#match? @fn "^(describe|it|test|context)$")) 
      arguments: (arguments . (string ((string_fragment) @testname)))) @testfn)
    ]]
  )
  local tree = vim.treesitter.get_parser():parse()
  local cursor_row = api.nvim_win_get_cursor(0)[1]
  local closest = nil
  for id, node, _ in query:iter_captures(tree[1]:root(), 0) do
    local name = query.captures[id]
    if name == "testname" then
      local row1, _, row2, _ = node:range()
      -- rows are 0-indexed
      row1 = row1 + 1
      row2 = row2 + 1
      -- if the cursor is in the test it's easy
      if row1 <= cursor_row and row2 >= cursor_row then
        return vim.treesitter.query.get_node_text(node, 0)
      end
      -- cursor not in this test, so check if it's near the cursor.
      -- we're iterating in order so keep setting the closest to the current
      -- node as long as it's before the cursor; if we've passed the cursor and
      -- still haven't found a test, set it to the one closest to the test after
      -- the cursor, then stop.
      if row2 < cursor_row or closest == nil then
        closest = node
      end
    end
  end
  if closest ~= nil then
    return vim.treesitter.query.get_node_text(closest, 0)
  end
  return nil
end

local function find_nearest_regex()
  vim.notify(
    "couldn't find test from treesitter, falling back to regex",
    vim.log.levels.ERROR
  )
  local test = find_nearest_test(
    [[^\s*\(it\|describe\|test\|context\)(["'']\(.*\)["''],]],
    3
  )
  if test ~= nil then
    return vim.fn.substitute(test, [[\([{\[(+)\]}]\)]], [[\\\1]], "g")
  end
  return nil
end

local function find_nearest()
  return find_nearest_treesitter() or find_nearest_regex()
end

local function npm_or_yarn()
  if vim.b.z_test_runner_npm_or_yarn == nil then
    if vim.fn.findfile("yarn.lock", ";") ~= "" then
      vim.b.z_test_runner_npm_or_yarn = "yarn"
    else
      vim.b.z_test_runner_npm_or_yarn = "npm"
    end
  end
  return vim.b.z_test_runner_npm_or_yarn
end

local function mocha(selection, pretest)
  local cmd = "npx mocha -- spec " .. vim.fs.normalize(api.nvim_buf_get_name(0))
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
  return npm_or_yarn() .. " test"
end

local function jest(selection)
  local cmd = npm_or_yarn() .. " test"
  if vim.startswith(cmd, "npm") then
    cmd = cmd .. " --"
  end
  if selection == "nearest" then
    local nearest = find_nearest()
    if nearest ~= nil then
      return cmd .. " -t " .. vim.fn.shellescape(find_nearest())
    end
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
    return mocha(selection, scripts.pretest or "")
  elseif test_cmd:match("jest") then
    return jest(selection)
  end
  if #test_cmd > 0 then
    return npm_or_yarn() .. " test"
  end
end

return {
  find_nearest_treesitter = find_nearest_treesitter,
  find_nearest_regex = find_nearest_regex,
  npm_or_yarn = npm_or_yarn,
  mocha = mocha,
  jest = jest,
  test = test,
}
