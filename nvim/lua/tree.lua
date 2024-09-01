local M = {}

---@param dir string
---@return string
local function create_raw_output(dir)
  local cmd = dir == vim.fs.normalize("~") .. "/" and "ls -1p ~"
    or ("(cd '%s' && rg --hidden -g'!.git/' --files 2>/dev/null | sort)"):format(
      dir
    )
  return io.popen(cmd):read("*all")
end

---@param output string[]
---@return table
function M.create_data_structure(output)
  local ret = {}
  for _, line in ipairs(output) do
    if line:ends_with("/") then
      -- special case for an empty directory, which only happens with the `ls`
      -- command above. rg does not return empty directories in its output.
      ret[line:sub(1, -2)] = {}
    else
      local ref = ret
      local pieces = line:split("/")
      for i, piece in ipairs(pieces) do
        if i == #pieces then
          table.insert(ref, piece)
        else
          if type(ref[piece]) ~= "table" then
            ref[piece] = {}
          end
          ref = ref[piece]
        end
      end
    end
  end
  return ret
end

---@param data table
---@param indent integer?
---@return string[]
function M.format(data, indent)
  indent = indent or 0
  local ret = {}
  local keys = vim.tbl_keys(data)
  -- sort directories alphabetically and list them first
  local dirs = vim.tbl_filter(function(key)
    return type(key) == "string"
  end, keys)
  table.sort(dirs)
  for _, dir in ipairs(dirs) do
    local work_data = vim.deepcopy(data)
    local collapsed = {}
    while
      type(work_data[dir]) == "table"
      and not vim.islist(work_data[dir])
      and vim.tbl_count(work_data[dir]) == 1
    do
      table.insert(collapsed, dir)
      work_data = work_data[dir]
      dir = vim.tbl_keys(work_data)[1]
    end
    if #collapsed > 0 then
      table.insert(collapsed, dir) -- add current dir to stack
      table.insert(
        ret,
        ("  "):rep(indent) .. table.concat(collapsed, "/") .. "/"
      )
    else
      table.insert(ret, ("  "):rep(indent) .. dir .. "/")
    end
    vim.list_extend(ret, M.format(work_data[dir], indent + 1))
  end
  -- then sort the files alphabetically and list them
  local file_keys = vim.tbl_filter(function(key)
    return type(key) == "number"
  end, keys)
  local files = vim.tbl_map(function(key)
    return data[key]
  end, file_keys)
  table.sort(files)
  for _, file in ipairs(files) do
    table.insert(ret, ("  "):rep(indent) .. file)
  end
  return ret
end

local function close()
  local buf = vim.api.nvim_get_current_buf()
  vim.cmd.wincmd("p")
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
  M.sidebar_tree_buffer = nil
end

---@return string
function M.find_full_path(line_number, lines)
  line_number = line_number or unpack(vim.api.nvim_win_get_cursor(0))
  lines = lines or vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local current_line = lines[line_number]
  local ret = { current_line:trim() }
  local current_indent = current_line:visual_indent()
  if current_indent > 0 then
    for i = line_number - 1, 1, -1 do
      local line = lines[i]
      local indent = line:visual_indent()
      if indent < current_indent then
        table.insert(ret, 1, line:trim())
        current_indent = indent
      end
      if indent == 0 then
        break
      end
    end
  end
  return vim.b.tree_dir .. table.concat(ret, "")
end

local function open_line(previous)
  local path = M.find_full_path()
  if path:ends_with("/") then
    M.tree(path)
  else
    local reopen = previous and #vim.api.nvim_list_wins() == 1
    if previous and #vim.api.nvim_list_wins() > 1 then
      -- we're in the tree sidebar and want to open a file in the previous
      -- window, and also not close the sidebar
      vim.cmd.wincmd("p")
    else
      -- otherwise close the sidebar and open the file in the previous window
      close()
    end
    vim.cmd.edit(path)
    if reopen then
      -- we opened the file in the previous window, now we need to reopen the
      -- tree sidebar and then move back to the previous window again
      M.tree_toggle()
      vim.cmd.wincmd("p")
    end
  end
end

local function visual_open_lines()
  -- force leave visual mode to update marks
  vim.api.nvim_feedkeys(vim.keycode("<C-c>"), "nx", false)
  local top = vim.api.nvim_buf_get_mark(0, "<")[1]
  local bottom = vim.api.nvim_buf_get_mark(0, ">")[1]
  local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local paths = {}
  for line_number = top, bottom do
    local path = M.find_full_path(line_number, buf_lines)
    -- ignore directories when opening multiple files
    if not path:ends_with("/") then
      table.insert(paths, path)
    end
  end
  for i, path in ipairs(paths) do
    vim.cmd[i == 1 and "edit" or "badd"](path)
  end
end

local function add_at_dir()
  local path = M.find_full_path()
  if not path:ends_with("/") then
    path = path:gsub("[^/]+$", "")
  end
  if #vim.api.nvim_list_wins() > 1 then
    -- move to non-tree window to open file
    vim.cmd.wincmd("p")
  end
  vim.api.nvim_feedkeys(":e " .. path, "", false)
end

local function parent_dir()
  local new_dir = vim.fs.dirname(vim.b.tree_dir)
  if vim.b.tree_dir:ends_with("/") then
    new_dir = vim.fs.dirname(new_dir)
  end
  M.tree(new_dir .. "/")
end

local function refresh()
  local saved_view = vim.fn.winsaveview()
  M.tree(vim.b.tree_dir)
  vim.fn.winrestview(saved_view)
end

local function move_file()
  local path = M.find_full_path()
  local path_buf = vim.fn.bufnr(path)
  if path_buf ~= -1 then
    if
      vim.fn.confirm(
        ("%s is currently open in buffer %s. Do you still want to rename it?"):format(
          path,
          path_buf
        ),
        "&Yes\n&No",
        2
      ) ~= 1
    then
      return
    end
  end
  vim.ui.input({ prompt = "Rename file:", default = path }, function(new_name)
    if new_name and new_name ~= "" then
      local result = vim.uv.fs_rename(path, new_name)
      if not result then
        vim.notify("Failed to rename file " .. path, vim.log.level.ERROR)
        return
      end
      refresh()
    end
  end)
end

local function set_buf_options_and_keymaps()
  -- options
  vim.opt_local.bufhidden = "delete"
  vim.opt_local.buftype = "nofile"
  vim.opt_local.colorcolumn = nil
  vim.opt_local.cursorcolumn = true
  vim.opt_local.filetype = "tree"
  vim.opt_local.statusline = "%{b:tree_dir}"
  vim.opt_local.textwidth = 0
  vim.opt_local.wrap = false
  -- keymaps
  local opts = { buffer = true, silent = true }
  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<CR>", open_line, opts)
  vim.keymap.set("n", "o", function()
    open_line(true)
  end, opts)
  vim.keymap.set("v", "<CR>", visual_open_lines, opts)
  vim.keymap.set("n", "a", add_at_dir, opts)
  vim.keymap.set("n", "g-", parent_dir, opts)
  vim.keymap.set("n", "R", refresh, opts)
  vim.keymap.set("n", "m", move_file, opts)
  -- delete the reference to the sidebar tree buffer if we switch to a new
  -- buffer in the tree window
  vim.api.nvim_create_autocmd("BufUnload", {
    buffer = 0,
    callback = function()
      M.sidebar_tree_buffer = nil
    end,
    once = true,
  })
end

---@return boolean
local function buf_is_empty()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return #lines == 1 and lines[1] == ""
end

---@param dir string?
function M.tree(dir)
  dir = vim.fs.normalize(dir or vim.uv.cwd())
  if not dir:ends_with("/") then
    dir = dir .. "/"
  end
  if vim.bo.filetype ~= "tree" and not buf_is_empty() then
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
  end
  set_buf_options_and_keymaps()
  vim.b.tree_dir = dir
  local output = create_raw_output(dir)
  local structure = M.create_data_structure(output:split("\n"))
  local lines = M.format(structure)
  vim.opt_local.modifiable = true
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.opt_local.modifiable = false
end

---@param dir string?
---@return integer?
local function open_sidebar(dir)
  -- don't open a sidebar if buf is an unnamed empty buffer
  if vim.api.nvim_buf_get_name(0) == "" and buf_is_empty() then
    M.tree(dir)
    return
  end
  local width = math.floor(math.max(vim.o.columns / 4, 35))
  vim.api.nvim_open_win(0, true, {
    split = "left",
    win = -1,
    width = width,
  })
  M.tree(dir)
  return vim.api.nvim_get_current_buf()
end

local function go_to_sidebar()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == M.sidebar_tree_buffer then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

function M.tree_toggle()
  if
    M.sidebar_tree_buffer
    and vim.api.nvim_get_current_buf() ~= M.sidebar_tree_buffer
  then
    go_to_sidebar()
  elseif vim.bo.filetype ~= "tree" then
    M.sidebar_tree_buffer = open_sidebar()
  else
    close()
  end
end

---@param args table
local function on_bufenter(args)
  if
    vim.tbl_contains({ "unload", "delete", "wipe" }, vim.bo[args.buf].bufhidden)
  then
    return
  end
  local stat = vim.uv.fs_stat(args.file)
  if stat and stat.type == "directory" then
    M.tree(args.file)
  end
end

function M.init()
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = on_bufenter,
    group = vim.api.nvim_create_augroup("tree", {}),
  })
  vim.api.nvim_create_user_command("Tree", function(args)
    open_sidebar(args.args ~= "" and args.args or nil)
  end, { nargs = "?", bar = true })
  vim.keymap.set("n", "-", M.tree_toggle)
end

return M
