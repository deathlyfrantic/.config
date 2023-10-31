local M = {}

local function poscmd()
  return vim.fn.getcmdpos(), vim.fn.getcmdline()
end

function M.kill_line()
  local pos, cmd = poscmd()
  if pos == 1 then
    return ""
  end
  return cmd:sub(1, pos - 1)
end

function M.delete_word()
  local pos, cmd = poscmd()
  local stop = pos
  while cmd:sub(stop + 1, stop + 1):match("[^%w]") and stop < #cmd do
    stop = stop + 1
  end
  while stop < #cmd do
    if cmd:sub(stop + 1, stop + 1):match("[^%w]") then
      break
    end
    stop = stop + 1
  end
  if pos == 1 then
    return cmd:sub(stop + 1)
  end
  return cmd:sub(0, pos - 1) .. cmd:sub(stop + 1)
end

function M.bwd_by_word()
  local pos, cmd = poscmd()
  if pos ~= 1 then
    local saw_letter = false
    for i = pos - 1, 0, -1 do
      saw_letter = saw_letter or cmd:sub(i, i):match("%w") ~= nil
      if cmd:sub(i, i):match("%w") == nil and saw_letter then
        break
      end
      vim.fn.setcmdpos(i)
    end
  end
  return cmd
end

function M.fwd_by_word()
  local pos, cmd = poscmd()
  local cmdlen = #cmd
  if pos < cmdlen then
    local saw_letter = false
    for i = pos, cmdlen do
      saw_letter = saw_letter or cmd:sub(i, i):match("%w") ~= nil
      if cmd:sub(i, i):match("%w") == nil and saw_letter then
        break
      end
      vim.fn.setcmdpos(i + 1)
    end
  end
  return cmd
end

return M
