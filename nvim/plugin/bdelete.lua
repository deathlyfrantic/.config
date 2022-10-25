local api = vim.api
local z = require("z")

local e89 = "E89: No write since last change for buffer %d (add ! to override)"

local function delete_current(force)
  local buf = api.nvim_get_current_buf()
  if vim.bo[buf].modified and not force then
    api.nvim_err_writeln(e89:format(buf))
    return
  end
  if vim.fn.bufexists(0) == 1 and vim.fn.buflisted(0) == 1 then
    vim.cmd.buffer("#")
  else
    local bufs = vim.tbl_filter(function(b)
      return z.buf_is_real(b)
    end, api.nvim_list_bufs())
    for _, b in ipairs(z.tbl_reverse(bufs)) do
      if b ~= buf then
        api.nvim_set_current_buf(b)
        break
      end
    end
  end
  api.nvim_buf_delete(buf, { force = force })
end

local function delete_by_name(force, name, term)
  local bufs = vim.tbl_filter(function(b)
    local bufname = api.nvim_buf_get_name(b)
    return z.buf_is_real(b)
      and (bufname == name or bufname:match(name))
      and (vim.bo[b].buftype ~= "terminal" or term)
  end, api.nvim_list_bufs())
  for _, b in ipairs(bufs) do
    if vim.bo[b].modified and not force then
      api.nvim_err_writeln(e89:format(b))
      return
    end
  end
  for _, b in ipairs(bufs) do
    api.nvim_buf_delete(b, { force = force })
  end
end

local function bdelete(args)
  local force = args.bang
  if #args.args == 0 then
    delete_current(force)
    return
  end
  local name = args.args
  local arg = string.lower(name)
  if arg == "man" then
    delete_by_name(true, "^man://", false)
  elseif arg:match("^term") then
    delete_by_name(true, "^term://", true)
  else
    delete_by_name(force, name, false)
  end
end

local function completion(arglead)
  local bufs = vim.tbl_map(
    function(b)
      return api.nvim_buf_get_name(b)
    end,
    vim.tbl_filter(function(b)
      return z.buf_is_real(b)
    end, api.nvim_list_bufs())
  )
  table.insert(bufs, "man")
  table.insert(bufs, "terminal")
  -- try to match against starting with arglead first
  local start_with = vim.tbl_filter(function(b)
    return vim.startswith(b, arglead)
  end, bufs)
  if #start_with > 0 then
    return start_with
  end
  -- if that doesn't work, return anything that contains the arglead
  return vim.tbl_filter(function(b)
    return b:match(arglead)
  end, bufs)
end

api.nvim_create_user_command(
  "Bdelete",
  bdelete,
  { bang = true, bar = true, complete = completion, nargs = "*" }
)
