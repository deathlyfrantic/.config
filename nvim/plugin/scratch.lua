local utils = require("utils")

---@param name string
local function save_file(name)
  return vim.fs.normalize(
    ("%s/scratch-%s.txt"):format(vim.fn.stdpath("data"), name)
  )
end

---@param name string
---@return string
local function bufname(name)
  return ("__Scratch-%s__"):format(name)
end

---@return integer
local function height()
  return math.min(10, math.floor(vim.o.lines / 3))
end

---@param name string
local function read(name)
  local pos = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_set_lines(0, 0, -1, true, {})
  local new_lines = utils.collect(io.open(save_file(name)):lines())
  vim.api.nvim_buf_set_lines(0, 0, -1, true, new_lines)
  vim.api.nvim_win_set_cursor(0, pos)
  vim.b.ftime = os.time()
end

---@param name string
local function write(name)
  local contents = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  local f = io.open(save_file(name), "w")
  if not f then
    vim.notify(
      ("Unable to open file '%s' for saving."):format(name),
      vim.log.levels.ERROR
    )
    return
  end
  f:write(table.concat(contents, "\n") .. "\n")
  f:close()
  vim.b.ftime = os.time()
end

---@param name string
local function close_window(name)
  local stat = vim.loop.fs_stat(save_file(name))
  local bftime = vim.b.ftime
  local close = function()
    vim.cmd.close({ count = vim.fn.bufwinnr(bufname(name)) })
  end
  if not stat or not bftime or bftime >= stat.mtime.sec then
    write(name)
    close()
  elseif stat and bftime and bftime < stat.mtime.sec then
    if
      vim.fn.confirm(
        "Scratch buffer changed since loading. Write anyway?",
        "&Yes\n&No",
        2
      ) == 1
    then
      write(name)
      close()
    end
  end
end

---@param name string
local function new_buffer(name)
  vim.cmd.new({
    args = { bufname(name) },
    mods = { split = "topleft" },
    range = { height() },
  })
  vim.opt_local.filetype = "scratch"
  vim.opt_local.buflisted = false
  vim.opt_local.bufhidden = "hide"
  vim.opt_local.buftype = "nofile"
  vim.opt_local.formatoptions = vim.opt_local.formatoptions - "o" - "r"
  vim.opt_local.swapfile = false
  vim.opt_local.textwidth = 0
  vim.opt_local.winfixheight = true
  vim.opt_local.winfixwidth = true
  vim.opt_local.statusline = "[Scratch/" .. name .. "]%=%l,%c%V%6P"
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.keymap.set("n", "q", "<C-w>q", { buffer = true, silent = true })
  vim.keymap.set("n", "R", function()
    read(name)
  end, { buffer = true, silent = true })
  vim.keymap.set("n", "<leader>s", "<C-w>p", { buffer = true, silent = true })
  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = 0,
    callback = function()
      close_window(name)
    end,
    group = vim.api.nvim_create_augroup("augroup-scratch-" .. name, {}),
  })
end

---@param name string
local function open_buffer(name)
  local bnum = vim.fn.bufnr(bufname(name))
  local stat = vim.loop.fs_stat(save_file(name))
  if bnum == -1 then
    new_buffer(name)
    if stat then
      read(name)
    end
  else
    local winid = vim.fn.bufwinid(bnum)
    if winid == -1 then
      vim.cmd.split({ mods = { split = "topleft" }, range = { height() } })
      vim.cmd.buffer(bnum)
    else
      vim.api.nvim_set_current_win(winid)
    end
    if stat and stat.mtime.sec > (vim.b.ftime or 0) then
      read(name)
    end
  end
end

---@param name string
local function selection(name)
  local contents = vim.fn.getreg('"')
  local regtype = vim.fn.getregtype('"')
  vim.cmd.normal({ args = { "y" }, bang = true })
  open_buffer(name)
  vim.api.nvim_buf_set_lines(0, 0, -1, true, {})
  vim.api.nvim_paste(vim.fn.getreg('"'), false, -1)
  vim.fn.setreg('"', contents, regtype)
end

---@param args string | { args: string, count: integer }
local function scratch(args)
  local name = "0"
  if type(args) == "string" then
    name = args
  elseif #args.args > 0 then
    name = args.args
  elseif args.count > -1 then
    name = tostring(args.count)
  end
  open_buffer(name)
end

---@param arglead string
---@return string[]
local function completion(arglead)
  local ret = {}
  local handle = vim.loop.fs_scandir(vim.fn.stdpath("data"))
  local name, kind = vim.loop.fs_scandir_next(handle)
  while name do
    if kind == "file" and name:match("scratch-.*%.txt") then
      local candidate = name:gsub("scratch%-", ""):gsub("%.txt", "")
      table.insert(ret, candidate)
    end
    name, kind = vim.loop.fs_scandir_next(handle)
  end
  return vim.tbl_filter(function(s)
    return s:starts_with(arglead)
  end, ret)
end

vim.api.nvim_create_user_command(
  "ScratchBuffer",
  scratch,
  { complete = completion, nargs = "?" }
)

vim.keymap.set("n", "<leader>s", function()
  open_buffer(vim.v.count)
end, { silent = true })
vim.keymap.set("x", "<leader>s", function()
  selection(vim.v.count)
end, { silent = true })
