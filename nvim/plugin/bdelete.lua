local utils = require("utils")

local e89 = "E89: No write since last change for buffer %d (add ! to override)"

local function delete_current(force)
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].modified and not force then
    vim.notify(e89:format(buf), vim.log.levels.ERROR)
    return
  end
  if vim.fn.bufexists(0) == 1 and vim.fn.buflisted(0) == 1 then
    vim.cmd.buffer("#")
  else
    local bufs = vim.tbl_filter(function(b)
      return utils.buf_is_real(b)
    end, vim.api.nvim_list_bufs())
    for i = #bufs, 1, -1 do
      if bufs[i] ~= buf then
        vim.api.nvim_set_current_buf(bufs[i])
        break
      end
    end
  end
  vim.api.nvim_buf_delete(buf, { force = force })
end

local function delete_by_name(force, name, term)
  local bufs = vim.tbl_filter(function(b)
    local bufname = vim.api.nvim_buf_get_name(b)
    return utils.buf_is_real(b)
      and bufname:match(name)
      and (vim.bo[b].buftype ~= "terminal" or term)
  end, vim.api.nvim_list_bufs())
  for _, b in ipairs(bufs) do
    if vim.bo[b].modified and not force then
      vim.notify(e89:format(b), vim.log.levels.ERROR)
      return
    end
  end
  for _, b in ipairs(bufs) do
    vim.api.nvim_buf_delete(b, { force = force })
  end
end

local function bdelete(args)
  local force = args.bang
  if #args.args == 0 then
    delete_current(force)
    return
  end
  local name = args.args
  local arg = name:lower()
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
      return vim.api.nvim_buf_get_name(b)
    end,
    vim.tbl_filter(function(b)
      return utils.buf_is_real(b)
    end, vim.api.nvim_list_bufs())
  )
  table.insert(bufs, "man")
  table.insert(bufs, "terminal")
  -- try to match against starting with arglead first
  local start_with = vim.tbl_filter(function(b)
    return b:starts_with(arglead)
  end, bufs)
  if #start_with > 0 then
    return start_with
  end
  -- if that doesn't work, return anything that contains the arglead
  return vim.tbl_filter(function(b)
    return b:match(arglead)
  end, bufs)
end

vim.api.nvim_create_user_command(
  "Bdelete",
  bdelete,
  { bang = true, bar = true, complete = completion, nargs = "*" }
)
