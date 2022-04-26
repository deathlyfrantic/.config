local api = vim.api
local z = require("z")

local function save_file(name)
  return vim.fn.expand(
    string.format("%s/scratch-%s.txt", vim.fn.stdpath("data"), name)
  )
end

local function bufname(name)
  return string.format("__Scratch-%s__", name)
end

local function height()
  return math.min(10, math.floor(vim.o.lines / 3))
end

local function read(name)
  local pos = api.nvim_win_get_cursor(0)
  api.nvim_buf_set_lines(0, 0, -1, true, {})
  local new_lines = z.collect(io.open(save_file(name)):lines())
  api.nvim_buf_set_lines(0, 0, -1, true, new_lines)
  api.nvim_win_set_cursor(0, pos)
  vim.b.ftime = os.time()
end

local function write(name)
  local contents = api.nvim_buf_get_lines(0, 0, -1, true)
  local f = io.open(save_file(name), "w")
  f:write(table.concat(contents, "\n") .. "\n")
  f:close()
  vim.b.ftime = os.time()
end

local function close_window(name)
  local stat = vim.loop.fs_stat(save_file(name))
  local bftime = vim.b.ftime
  local close = function()
    vim.cmd(vim.fn.bufwinnr(bufname(name)) .. "close")
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

local function new_buffer(name)
  vim.cmd(string.format("topleft %snew %s", height(), bufname(name)))
  vim.opt_local.filetype = "scratch"
  vim.opt_local.buflisted = false
  vim.opt_local.bufhidden = "hide"
  vim.opt_local.buftype = "nofile"
  vim.opt_local.formatoptions:remove("o"):remove("r")
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
  api.nvim_create_autocmd("WinLeave", {
    buffer = 0,
    callback = function()
      close_window(name)
    end,
    group = api.nvim_create_augroup("augroup-scratch-" .. name, {}),
  })
end

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
      vim.cmd(string.format("topleft %ssplit +buffer%s", height(), bnum))
    else
      api.nvim_set_current_win(winid)
    end
    if stat and stat.mtime.sec > (vim.b.ftime or 0) then
      read(name)
    end
  end
end

local function selection(name)
  local contents = vim.fn.getreg('"')
  local regtype = vim.fn.getregtype('"')
  vim.cmd("normal! y")
  open_buffer(name)
  api.nvim_buf_set_lines(0, 0, -1, true, {})
  api.nvim_paste(vim.fn.getreg('"'), false, -1)
  vim.fn.setreg('"', contents, regtype)
end

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

local function completion()
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
  return ret
end

api.nvim_create_user_command(
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
