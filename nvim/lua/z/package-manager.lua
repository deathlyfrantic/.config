local packages = {}

local path_base = vim.fn.stdpath("config") .. "/pack/z/"

local function dir_exists(dir)
  local stat = vim.loop.fs_stat(dir)
  return stat and stat.type == "directory"
end

local function popup_window(title, contents, callback)
  -- remove empty last line if there is one
  if contents[#contents]:is_empty() then
    contents[#contents] = nil
  end
  local height = math.min(#contents, math.floor(vim.o.lines - 10))
  local longest = math.max(unpack(vim.tbl_map(string.len, contents)))
  local width = math.floor(math.min(longest, vim.o.columns - 10))
  local opts = {
    relative = "editor",
    style = "minimal",
    border = "single",
    height = height,
    width = width,
    row = math.floor(vim.o.lines / 2) - math.floor(height / 2) - 2,
    col = math.floor(vim.o.columns / 2) - math.floor(width / 2),
    anchor = "NW",
    title = " " .. title .. " ",
    title_pos = "center",
    noautocmd = true,
  }
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, contents)
  vim.bo[buf].modifiable = false
  local win_id = vim.api.nvim_open_win(buf, true, opts)
  vim.opt.winhl:append("Normal:Normal")
  vim.opt.winhl:append("FloatBorder:Normal")
  local close = function()
    vim.api.nvim_win_close(win_id, true)
  end
  vim.keymap.set("n", "q", close, { silent = true, buffer = buf })
  vim.keymap.set("n", "<Esc>", close, { silent = true, buffer = buf })
  if vim.is_callable(callback) then
    callback(buf)
  end
end

local function run_jobs(cmds)
  local jobs, results = {}, {}
  for name, cmd in pairs(cmds) do
    results[name] = {}
    table.insert(
      jobs,
      vim.fn.jobstart(cmd, {
        on_exit = function(_, code, _)
          results[name].success = code == 0
        end,
        on_stderr = function(_, output, _)
          results[name].stderr = output
        end,
        on_stdout = function(_, output, _)
          results[name].stdout = output
        end,
        stderr_buffered = true,
        stdout_buffered = true,
      })
    )
  end
  vim.fn.jobwait(jobs)
  return results
end

local function clean()
  local installed = {}
  for name, type in vim.fs.dir(path_base, { depth = 2 }) do
    -- filter out non-directories, and the "start" and "opt" directories
    if name ~= "start" and name ~= "opt" and type == "directory" then
      table.insert(installed, path_base .. name)
    end
  end
  local specified = vim.tbl_map(function(spec)
    return spec.path
  end, vim.tbl_values(packages))
  local need_to_remove = vim.tbl_filter(function(path)
    return not vim.tbl_contains(specified, path)
  end, installed)
  if #need_to_remove == 0 then
    vim.notify(
      "No package directories need to be removed.",
      vim.log.levels.INFO
    )
    return
  end
  vim.ui.select({ "Yes", "No" }, {
    prompt = "The following directories will be removed:\n\n" .. table.concat(
      vim.tbl_map(function(dir)
        return "  - " .. dir
      end, need_to_remove),
      "\n"
    ) .. "\n\nDo you want to remove these directories?",
  }, function(choice)
    if choice == "Yes" then
      local successes, failures = "", ""
      for _, path in ipairs(need_to_remove) do
        if vim.fn.delete(path, "rf") == 0 then
          successes = successes .. " - " .. path .. "\n"
        else
          failures = failures .. " - " .. path .. "\n"
        end
      end
      if #successes > 0 then
        vim.notify(
          "Successfully deleted directories:\n\n" .. successes,
          vim.log.levels.INFO
        )
      end
      if #failures > 0 then
        vim.notify(
          "Failed to delete directories:\n\n" .. failures,
          vim.log.levels.ERROR
        )
      end
    end
  end)
end

local function install()
  local need_to_install = vim.tbl_filter(function(spec)
    return not dir_exists(spec.path)
  end, packages)
  if #need_to_install == 0 then
    vim.notify("No packages to install.", vim.log.levels.INFO)
    return
  end
  vim.notify(
    ("Installing %s packages ..."):format(#need_to_install),
    vim.log.levels.INFO
  )
  vim.cmd.redraw({ bang = true })
  local cmds = {}
  for _, spec in ipairs(need_to_install) do
    cmds[spec.name] = ("git clone %s %s"):format(spec.url, spec.path)
  end
  local job_results = run_jobs(cmds)
  local successes, failures = {}, {}
  for name, result in pairs(job_results) do
    if result.success then
      table.insert(successes, name)
    else
      failures[name] = result
    end
  end
  local output = {}
  if #successes > 0 then
    table.insert(output, "Successfully installed:")
    for _, name in ipairs(successes) do
      table.insert(output, "  ✓ " .. name)
    end
    table.insert(output, "")
  end
  if vim.tbl_count(failures) > 0 then
    table.insert(output, "Failed to install:")
    for name, data in pairs(failures) do
      table.insert(output, "  ✗ " .. name)
      for _, line in ipairs(data.stderr) do
        table.insert(output, "      " .. line)
      end
    end
  end
  popup_window("Package Install", output)
end

local function open_diff()
  local pieces = vim.api
    .nvim_get_current_line()
    :trim()
    :split(" ", { plain = true, trimempty = true })
  if pieces == 0 or not pieces[1]:match("^[0-9A-Fa-f]+$") then
    return
  end
  local commit = pieces[1]
  local row = vim.api.nvim_win_get_cursor(0)[1]
  while row > 0 do
    row = row - 1
    local lines = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
    if #lines == 0 then
      return
    end
    pieces = lines[1]:trim():split(" ", { plain = true, trimempty = true })
    if pieces[1] == "✓" then
      local package = packages[pieces[2]]
      popup_window(
        package.name .. " commit " .. commit,
        vim.fn.systemlist("git -C " .. package.path .. " show " .. commit),
        function()
          vim.wo.cursorline = true
          vim.bo.filetype = "git"
        end
      )
      return
    end
  end
end

local function update()
  local cmds = {}
  for name, spec in pairs(packages) do
    if not dir_exists(spec.path) then
      vim.notify(
        ("Need to install package '%s'"):format(spec.name),
        vim.log.levels.ERROR
      )
      return
    end
    cmds[name] = ("git -C %s pull --ff-only --no-rebase"):format(spec.path)
  end
  vim.notify("Updating packages ...", vim.log.levels.INFO)
  vim.cmd.redraw({ bang = true })
  local job_results = run_jobs(cmds)
  local git_logs = {}
  for name, spec in pairs(packages) do
    if
      job_results[name].success
      and job_results[name].stdout[1] ~= "Already up to date."
    then
      git_logs[name] = vim.fn.systemlist(
        "git -C "
          .. spec.path
          .. " log --format='%h %s' --no-color HEAD@{1}..HEAD"
      )
    end
  end
  local successes, failures = {}, {}
  for name, result in pairs(job_results) do
    if result.success then
      if git_logs[name] then
        -- we should always get here, but to be safe, guard against missing
        -- output in `git_logs`
        table.insert(successes, name)
      end
    else
      failures[name] = result
    end
  end
  local output = {}
  if #successes > 0 then
    table.insert(output, "Successfully updated:")
    for _, name in ipairs(successes) do
      table.insert(output, "  ✓ " .. name)
      table.insert(
        output,
        "  URL: " .. packages[name].url:gsub("^github:", "https://github.com/")
      )
      table.insert(output, "  Commits:")
      for _, line in ipairs(git_logs[name]) do
        table.insert(output, "      " .. line)
      end
      table.insert(output, "")
      -- run post-update tasks
      local run = packages[name].run
      if run then
        -- run update functions outside of this loop since they might block
        vim.defer_fn(function()
          if vim.is_callable(run) then
            run()
          elseif type(run) == "string" and run:sub(1, 1) == ":" then
            vim.cmd(run:sub(2))
          end
        end, 500)
      end
    end
  end
  if vim.tbl_count(failures) > 0 then
    table.insert(output, "Failed to update:")
    for name, data in pairs(failures) do
      table.insert(output, "  ✗ " .. name)
      for _, line in ipairs(data.stderr) do
        table.insert(output, "      " .. line)
      end
    end
  end
  if #output > 0 then
    popup_window("Package Update", output, function(buf)
      vim.keymap.set(
        "n",
        "d",
        open_diff,
        { silent = true, buffer = buf, nowait = true }
      )
      vim.wo.cursorline = true
    end)
  else
    vim.notify("No packages needed to be updated.", vim.log.levels.INFO)
  end
end

local function create_package_spec(spec)
  -- make a string into a table
  if type(spec) == "string" then
    spec = { spec }
  end
  -- if spec isn't a table, then it also wasn't a string
  if type(spec) ~= "table" then
    error("Invalid package spec: %s (type is '%s' - must be string or table)"):format(
      tostring(spec),
      type(spec)
    )
  end
  local name = spec[1]
  local ret = {
    name = name,
    cmd = spec.cmd,
    config = spec.config,
    setup = spec.setup,
    run = spec.run,
    type = spec.cmd and "opt" or "start",
    url = name:find(":") and name or "github:" .. name,
    dir = name, -- might be changed by code after
  }
  -- given name like `user/repo`, use `repo` as the dir name
  local match = ret.name:match("/[^/]+$")
  if match then
    ret.dir = match:sub(2)
  end
  -- absolute path to package
  ret.path = ("%s%s/%s"):format(path_base, ret.type, ret.dir)
  return ret
end

local function run_user_code(spec, key)
  if vim.is_callable(spec[key]) then
    local ok, err = pcall(spec[key])
    if not ok then
      vim.notify(
        ("Error running %s for package '%s': %s"):format(
          key,
          spec.name,
          tostring(err)
        ),
        vim.log.levels.ERROR
      )
    end
  end
end

local function add(...)
  for _, pkg in ipairs({ ... }) do
    local spec = create_package_spec(pkg)
    packages[spec.name] = spec
    -- run setup code for all packages
    run_user_code(spec, "setup")
    if spec.type == "start" then
      -- immediately run config code for start packages
      run_user_code(spec, "config")
    else
      -- only run config for optional packages immediately before they are
      -- loaded
      if spec.cmd then
        vim.api.nvim_create_user_command(spec.cmd, function(opts)
          vim.api.nvim_del_user_command(spec.cmd)
          run_user_code(spec, "config")
          vim.cmd.packadd(spec.dir)
          local new_opts = {
            cmd = opts.name,
            mods = opts.smods,
            bang = opts.bang,
            args = opts.fargs,
          }
          if opts.range > 0 then
            new_opts.range = { opts.line1, opts.line2 }
          end
          vim.api.nvim_cmd(new_opts, {})
        end, { bar = true, bang = true, nargs = "*", range = true })
      end
    end
  end
end

local function init()
  packages = {}
  vim.api.nvim_create_user_command("PackageClean", clean, {})
  vim.api.nvim_create_user_command("PackageInstall", install, {})
  vim.api.nvim_create_user_command("PackageUpdate", update, {})
end

return {
  add = add,
  clean = clean,
  init = init,
  install = install,
  update = update,
}
