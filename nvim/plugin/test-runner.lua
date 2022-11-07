local api = vim.api

local test_buffer

local function get_match_lines(start, num)
  return table.concat(api.nvim_buf_get_lines(0, start, start + num, true), "\n")
end

local function find_nearest_test(pattern, atom)
  local num_lines = #vim.split(pattern, [[\n]])
  local match = vim.fn.matchlist(
    get_match_lines(api.nvim_win_get_cursor(0)[1] - 1, num_lines),
    pattern
  )
  if #match > 0 then
    return match[atom]
  end
  local before = vim.fn.search(pattern, "bnW")
  if before ~= 0 then
    return vim.fn.matchlist(get_match_lines(before - 1, num_lines), pattern)[atom]
  end
  local after = vim.fn.search(pattern, "nW")
  if after ~= 0 then
    return vim.fn.matchlist(get_match_lines(after - 1, num_lines), pattern)[atom]
  end
end

local function makefile_test()
  local makefile = vim.fn.findfile("Makefile", ";")
  if makefile == "" then
    return nil
  end
  local dir = vim.fs.dirname(makefile)
  for line in io.open(makefile):lines() do
    if line:match("^test:") then
      return string.format("(cd %s && make test)", dir)
    end
  end
end

local function find_nearest_rust_test_from_treesitter()
  local query = vim.treesitter.parse_query(
    vim.bo.filetype,
    [[((mod_item
      (((identifier) @mod-name (#eq? @mod-name "tests"))
        (declaration_list
          (attribute_item (meta_item (identifier) @attr (#eq? @attr "test")))
            . (function_item (identifier) (block)) @testfn)))
    )]]
  )
  local tree = vim.treesitter.get_parser():parse()
  local cursor_row = api.nvim_win_get_cursor(0)[1]
  local closest = nil
  for id, node, _ in query:iter_captures(tree[1]:root(), 0) do
    local name = query.captures[id]
    if name == "testfn" then
      local row1, _, row2, _ = node:range()
      -- rows are 0-indexed
      row1 = row1 + 1
      row2 = row2 + 1
      -- if the cursor is in the test it's easy
      if row1 <= cursor_row and row2 >= cursor_row then
        return vim.treesitter.query.get_node_text(node:field("name")[1], 0)
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
  return vim.treesitter.query.get_node_text(closest:field("name")[1], 0)
end

local function rust(selection)
  if not vim.fn.executable("cargo") then
    return nil
  end
  -- change to source dir in case file is in a subproject, but strip off the
  -- trailing "src" component e.g. /code/project/src/main.rs -> /code/project
  local cmd = string.format(
    "(cd %s && cargo test)",
    vim.fs.dirname(vim.fs.dirname(api.nvim_buf_get_name(0)))
  )
  if selection == "nearest" then
    local mod_tests_line = vim.fn.search("^mod tests {$", "n")
    if mod_tests_line == 0 then
      return cmd
    end
    local nearest = find_nearest_rust_test_from_treesitter()
    if nearest == nil then
      api.nvim_err_writeln(
        "couldn't find test from treesitter, falling back to regex"
      )
      nearest = find_nearest_test([[#\[test]\n\s*fn\s\+\(\w*\)(]], 2)
    end
    return cmd:sub(1, -2) .. string.format(" %s)", nearest)
  elseif selection == "file" then
    return cmd:sub(1, -2)
      .. string.format(
        " %s::)",
        vim.fn.basename(api.nvim_buf_get_name(0)):match("(.*)%.")
      )
  end
  return cmd
end

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

local function javascript(selection)
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

local test_runners = {
  javascript = javascript,
  make = makefile_test,
  rust = rust,
  typescript = javascript,
}

local function scroll_to_end()
  local current_window = api.nvim_get_current_win()
  for _, w in ipairs(vim.fn.win_findbuf(test_buffer)) do
    api.nvim_set_current_win(w)
    vim.cmd.normal("G")
  end
  api.nvim_set_current_win(current_window)
end

local function on_exit(...)
  local close, _, exit_code = select(1, ...)
  if exit_code == 0 then
    if close then
      vim.defer_fn(function()
        if api.nvim_buf_is_valid(test_buffer) then
          api.nvim_buf_delete(test_buffer, { force = true })
        end
      end, 1000)
    end
    api.nvim_echo(
      { { "Tests pass. (Test runner exit code was 0.)", "Success" } },
      false,
      {}
    )
  else
    scroll_to_end()
  end
end

-- function body declared below - this is a hack to avoid circular dependencies
local rerun

local function load_or_create_buffer()
  if test_buffer ~= nil and api.nvim_buf_is_valid(test_buffer) then
    api.nvim_set_current_buf(test_buffer)
  else
    test_buffer = api.nvim_create_buf(false, false)
    vim.bo[test_buffer].buftype = "nofile"
    vim.bo[test_buffer].modifiable = false
    api.nvim_set_current_buf(test_buffer)
    api.nvim_create_autocmd("BufDelete", {
      buffer = test_buffer,
      callback = function()
        test_buffer = nil
      end,
    })
    vim.keymap.set(
      "n",
      "q",
      ":bd!<CR>",
      { buffer = test_buffer, silent = true }
    )
    vim.keymap.set("n", "R", rerun, { buffer = test_buffer, silent = true })
  end
end

local function new_test_window()
  local height = math.floor(vim.o.lines / 3)
  vim.cmd("botright " .. height .. "split")
  load_or_create_buffer()
end

local function ensure_test_window()
  if #vim.fn.win_findbuf(test_buffer) < 1 then
    new_test_window()
  end
end

local function run_tests(cmd, close)
  ensure_test_window()
  api.nvim_set_current_win(vim.fn.win_findbuf(test_buffer)[1])
  vim.b.command = cmd
  vim.b.close = close
  vim.bo.modified = false
  vim.fn.termopen(cmd, {
    on_exit = function(...)
      on_exit(close, ...)
    end,
  })
  scroll_to_end()
end

rerun = function()
  vim.bo[test_buffer].modified = false
  vim.bo[test_buffer].modifiable = true
  local close = vim.b.close
  if close == nil then
    close = true
  end
  run_tests(vim.b.command, close)
end

local function test(selection, force)
  local test_cmds, errs = {}, {}
  local filetype = vim.bo.filetype
  if type(vim.b.test_command) == "string" then
    table.insert(test_cmds, vim.b.test_command)
  elseif
    type(vim.b.test_command) == "table"
    and vim.b.test_command[selection] ~= nil
  then
    if type(vim.b.test_command[selection]) == "string" then
      table.insert(test_cmds, vim.b.test_command[selection])
    else
      -- assuming this is a function here - doesn't make sense for it to be
      -- anything else. this is _insanity_ - there's no way to run a function
      -- stored in a buffer variable natively in lua, so we have to execute
      -- vimscript and echo the result, which we then capture as a string :oof:
      table.insert(
        test_cmds,
        api.nvim_exec("echo b:test_command." .. selection .. "()", true)
      )
    end
  elseif test_runners[filetype] ~= nil then
    local cmd = test_runners[filetype](selection)
    if cmd ~= nil then
      table.insert(test_cmds, cmd)
    end
  else
    table.insert(
      errs,
      string.format("No tests available for filetype '%s'", filetype)
    )
  end
  local maketest = makefile_test()
  if maketest ~= nil then
    table.insert(test_cmds, maketest)
  else
    table.insert(errs, "no `Makefile` found")
  end
  local current_window = api.nvim_get_current_win()
  if #test_cmds > 0 then
    run_tests(test_cmds[1], force)
  else
    api.nvim_err_writeln(table.concat(errs, " and "))
  end
  api.nvim_set_current_win(current_window)
end

local setup = {
  { cmd = "RunNearestTest", key = "t", param = "nearest" },
  { cmd = "RunTestFile", key = "T", param = "file" },
  { cmd = "RunTestSuite", key = "<C-t>", param = "all" },
}
for _, x in ipairs(setup) do
  local key, cmd, param = x.key, x.cmd, x.param
  api.nvim_create_user_command(cmd, function(args)
    test(param, not args.bang)
  end, { bang = true })
  vim.keymap.set(
    "n",
    "<leader>" .. key,
    ":" .. cmd .. "<CR>",
    { silent = true }
  )
  vim.keymap.set(
    "n",
    "g<leader>" .. key,
    ":" .. cmd .. "!<CR>",
    { silent = true }
  )
end

_G.test_runner = {
  -- expose this for use in local config files etc
  find_nearest_test = find_nearest_test,
}
