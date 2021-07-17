local api = vim.api
local autocmd = require("autocmd")
local z = require("z")

local test_buffer

local function get_match_lines(start, num)
  return table.concat(
    api.nvim_buf_get_lines(0, start, start + num, true),
    "\n"
  )
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
  local dir = vim.fn.fnamemodify(makefile, ":h")
  for line in io.open(makefile):lines() do
    if line:match("^test:") then
      return string.format("(cd %s && make test)", dir)
    end
  end
end

local function rust(selection)
  if not vim.fn.executable("cargo") then
    return nil
  end
  -- change to source dir in case file is in a subproject, but strip off the
  -- trailing "src" component e.g. /code/project/src/main.rs -> /code/project
  local cmd = string.format("(cd %s && cargo test)", vim.fn.expand("%:p:h:h", true))
  if selection == "nearest" then
    local mod_tests_line = vim.fn.search("^mod tests {$", "n")
    if mod_tests_line == 0 then
      return cmd
    end
    local nearest = find_nearest_test([[#\[test]\n\s*fn\s\+\(\w*\)(]], 2)
    return cmd:sub(1, -2) .. string.format(" %s)", nearest)
  elseif selection == "file" then
    return cmd:sub(1, -2)
      .. string.format(" %s::)", vim.fn.expand("%:t:r", true))
  end
  return cmd
end

local function find_nearest_javascript_test()
  local test = find_nearest_test([[^\s*\(it\|describe\)(["'']\(.*\)["''],]], 3)
  return vim.fn.substitute(test, [[\([{\[(+)\]}]\)]], [[\\\1]], "g")
end

local function npm_or_yarn()
  if vim.fn.findfile("yarn.lock", ";") ~= "" then
    return "yarn"
  end
  return "npm"
end

local function javascript_mocha(selection, pretest)
  local cmd = "npx mocha -- spec " .. vim.fn.expand("%:p", true)
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
  if selection == "nearest" then
    return cmd .. " -t " .. vim.fn.shellescape(find_nearest_javascript_test())
  elseif selection == "file" then
    return cmd .. " " .. vim.fn.expand("%:p", true)
  end
  return cmd
end

local function javascript(selection)
  local package_json = vim.fn.findfile("package.json", ";")
  if package_json == "" then
    return nil
  end
  local package = vim.fn.json_decode(io.open(package_json):read("*all"))
  local scripts = package.scripts or {}
  local test_cmd = scripts.test or ""
  if test_cmd:match("mocha") then
    return javascript_mocha(selection, scripts.pretest or "")
  elseif test_cmd:match("jest") then
    return javascript_jest(selection)
  end
  if #cmd > 0 then
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
    vim.cmd("normal G")
  end
  api.nvim_set_current_win(current_window)
end

local function on_exit(...)
  local close, job_id, exit_code, event = select(1, ...)
  if exit_code == 0 then
    if close then
      vim.defer_fn(
        function()
          api.nvim_buf_delete(test_buffer, { force = true })
        end,
        1000
      )
    end
    api.nvim_echo(
      {
        {
          "Tests pass. (Test runner exit code was 0.)",
          "GitGutterAdd",
        },
      },
      false,
      {}
    )
  else
    scroll_to_end()
  end
end

local function load_or_create_buffer()
  if test_buffer ~= nil and api.nvim_buf_is_valid(test_buffer) then
    api.nvim_set_current_buf(test_buffer)
  else
    test_buffer = api.nvim_create_buf(false, false)
    vim.bo[test_buffer].buftype = "nofile"
    vim.bo[test_buffer].modifiable = false
    api.nvim_set_current_buf(test_buffer)
    autocmd.add("BufDelete", "<buffer>", function()
      test_buffer = nil
    end)
    api.nvim_buf_set_keymap(
      test_buffer,
      "n",
      "q",
      ":bd!<CR>",
      { silent = true, noremap = true }
    )
    api.nvim_buf_set_keymap(
      test_buffer,
      "n",
      "R",
      [[:lua test_runner.rerun()<CR>]],
      { silent = true, noremap = true }
    )
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
end

local function rerun()
  vim.bo[test_buffer].modified = false
  vim.bo[test_buffer].modifiable = true
  local close = vim.b.close
  if close == nil then
    close = true
  end
  run_tests(vim.b.command, close)
end

local function test(selection, bang)
  local test_cmds, errs = {}, {}
  local filetype = vim.bo.filetype
  if type(vim.b.test_command) == "string" then
    table.insert(test_cmds, vim.b.test_command)
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
    run_tests(test_cmds[1], bang ~= "!")
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
  vim.cmd(string.format(
    [[command! -bang %s lua test_runner.test("%s", <q-bang>)]],
    cmd,
    param
  ))
  api.nvim_set_keymap(
    "n",
    "<leader>" .. key,
    ":" .. cmd .. "<CR>",
    { silent = true, noremap = true }
  )
  api.nvim_set_keymap(
    "n",
    "g<leader>" .. key,
    ":" .. cmd .. "!<CR>",
    { silent = true, noremap = true }
  )
end

_G.test_runner = {
  test = test,
  rerun = rerun,
  -- expose this for use in local config files etc
  find_nearest_test = find_nearest_test,
}
