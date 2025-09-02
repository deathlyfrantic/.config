local utils = require("utils")

local M = {}

---@return string
function M.star_cmd_str(height)
  if not M.star_cmd_color_args then
    local colors = {
      ["color-selected-bg"] = utils.get_hex_color("StatusLine", "bg"),
      ["color-matched-selected-fg"] = utils.get_hex_color("Comment", "fg"),
      ["color-matched-fg"] = utils.get_hex_color("String", "fg"),
      ["color-tag-fg"] = utils.get_hex_color("Warning", "fg"),
    }
    M.star_cmd_color_args = vim
      .iter(colors)
      :map(function(k, v)
        return ("--%s=%s"):format(k, v)
      end)
      :join(" ")
  end
  return ("star -m --height %s %s"):format(height, M.star_cmd_color_args)
end

---@param buf integer
---@param options table
local function popup_window(buf, options)
  local opts = {
    relative = "editor",
    style = "minimal",
    height = options.height,
    width = options.width,
    row = math.floor(vim.o.lines / 2) - math.floor(options.height / 2),
    col = math.floor(vim.o.columns / 2) - math.floor(options.width / 2),
    anchor = "NW",
    title = " Star ",
    title_pos = "center",
  }
  local win_id = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_win_set_hl_ns(
    win_id,
    vim.api.nvim_create_namespace("popup-window")
  )
end

function M.delete_buffer()
  if vim.api.nvim_buf_is_valid(M.buffer) then
    vim.api.nvim_buf_delete(M.buffer, { force = true })
  end
  M.buffer = nil
end

---@param lines string[]
function M.write_lines(lines)
  local f = io.open(M.infile, "w")
  if not f then
    error(("Unable to open infile '%s'."):format(M.infile))
  end
  f:write(table.concat(lines, "\n") .. "\n")
  f:close()
end

---@param lines string[]
---@param callback fun(choices: string[]): nil
function M.star(lines, callback)
  -- need to call find_project_dir() now before opening the star buffer so we
  -- use the cached value (which is a buffer variable)
  local name = ("Star(%s)"):format(utils.find_project_dir():sub(1, -2))
  M.write_lines(lines)
  local width = math.max(
    math.min(utils.longest(lines) + 2, vim.o.columns - 4),
    math.floor(vim.o.columns / 3)
  )
  local height = math.max(10, math.floor(vim.o.lines / 3))
  M.buffer = vim.api.nvim_create_buf(false, false)
  popup_window(M.buffer, { width = width, height = height })
  vim.bo[M.buffer].buftype = "nofile"
  vim.bo[M.buffer].modifiable = false
  local cmd = ([[(cd %s && %s < "%s" > "%s")]]):format(
    utils.find_project_dir(),
    M.star_cmd_str(height),
    M.infile,
    M.outfile
  )
  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function(_, exit_code)
      -- switch to previous window
      vim.api.nvim_set_current_win(vim.fn.win_getid(vim.fn.winnr("#")))
      -- delete star buffer
      M.delete_buffer()
      -- if we cancel out of star it exits with a non-zero code, so only try to
      -- do something if it exited successfully
      if exit_code == 0 then
        local f = io.open(M.outfile)
        if not f then
          error(("Unable to open outfile '%s'."):format(M.outfile))
        end
        local choices = f:read("*all"):splitlines(true)
        f:close()
        callback(choices)
      end
    end,
  })
  vim.b.term_title = name
  vim.cmd.startinsert()
end

---@param cmd string[]
---@return string[]
local function cmd_output(cmd)
  return vim
    .system(cmd, { cwd = utils.find_project_dir(), text = true })
    :wait().stdout
    :splitlines()
end

---@return Iter
local function normalized_buffers()
  return vim
    .iter(vim.api.nvim_list_bufs())
    -- filter out invalid buffers (nofile, scratch, etc)
    :filter(function(b)
      return utils.buf_is_real(b) and vim.api.nvim_buf_get_name(b) ~= ""
    end)
    -- normalize buffer names and remove cwd from them
    :map(function(b)
      local normalized, _ = vim.fs
        .normalize(vim.api.nvim_buf_get_name(b))
        :gsub(("^%s/"):format(vim.pesc(vim.uv.cwd())), "")
      return normalized
    end)
end

---@param exclude_open boolean
local function find_files_cmd(exclude_open)
  if vim.b.star_find_cmd then
    if type(vim.b.star_find_cmd) ~= "table" then
      error("buffer-local `star_find_cmd` variable must be a table.")
    end
    return vim.b.star_find_cmd
  end
  local cmd = { "rg", "--files" }
  if not exclude_open then
    return cmd
  end
  normalized_buffers()
    -- add `-g !filename` for each file to tell ripgrep to exclude it
    :each(
      function(f)
        vim.list_extend(cmd, { "-g", vim.fn.escape("!" .. f, " [") })
      end
    )
  return cmd
end

---@param files string[]
local function open_files(files)
  vim
    .iter(files)
    :map(function(f)
      return vim.fs.joinpath(utils.find_project_dir(), f)
    end)
    :enumerate()
    :each(function(i, f)
      if vim.uv.fs_access(f, "r") then
        vim.cmd[i == 1 and "edit" or "badd"](f)
      else
        vim.notify(("can't access '%s'"):format(f), vim.log.levels.ERROR)
      end
    end)
end

-- Find files, excluding those that are open
local function find_files()
  M.star(cmd_output(find_files_cmd(true)), open_files)
end

-- Find files, including those that are open
local function find_all_files()
  M.star(cmd_output(find_files_cmd(false)), open_files)
end

local function find_buffers()
  M.star(normalized_buffers():totable(), function(choices)
    local buf = choices[1]
    if not buf:starts_with("/") then
      buf = vim.fs.joinpath(vim.uv.cwd(), buf)
    end
    vim.api.nvim_set_current_buf(
      vim.uri_to_bufnr(vim.uri_from_fname(vim.fs.normalize(buf)))
    )
  end)
end

local function find_git_commits()
  local lines = cmd_output({
    "git",
    "log",
    "--pretty=format:%h%d :: %s [%cd - %an]",
    "--date=format:%d %b %Y",
    "--no-merges",
  })
  M.star(lines, function(choices)
    for _, commit in ipairs(choices) do
      vim.cmd.Git(("show %s"):format(commit:match("^%x+")))
    end
  end)
end

function M.init()
  M.buffer = nil
  M.infile = vim.fn.tempname()
  M.outfile = vim.fn.tempname()
  M.star_cmd_color_args = nil
  -- reset color args if colorscheme changes
  vim.api.nvim_create_autocmd({ "ColorScheme", "VimResized" }, {
    pattern = "*",
    callback = function()
      M.star_cmd_color_args = nil
    end,
    group = vim.api.nvim_create_augroup("star-colorscheme-reset", {}),
  })
  vim.keymap.set("n", "<C-p>", find_files)
  vim.keymap.set("n", "g<C-p>", find_all_files)
  vim.keymap.set("n", "g<C-b>", find_buffers)
  vim.keymap.set("n", "g<C-g>", find_git_commits)
end

return M
