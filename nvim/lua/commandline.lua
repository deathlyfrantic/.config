local M = {}

local function poscmd()
  return vim.fn.getcmdpos(), vim.fn.getcmdline()
end

function M.kill_line()
  local pos, cmd = poscmd()
  return pos == 1 and "" or cmd:sub(1, pos - 1)
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
  return pos == 1 and cmd:sub(stop + 1)
    or cmd:sub(0, pos - 1) .. cmd:sub(stop + 1)
end

function M.bwd_by_word()
  local pos, cmd = poscmd()
  if pos ~= 1 then
    local saw_letter = false
    for i = pos - 1, 0, -1 do
      saw_letter = saw_letter or cmd:sub(i, i):match("%w")
      if not cmd:sub(i, i):match("%w") and saw_letter then
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
      saw_letter = saw_letter or cmd:sub(i, i):match("%w")
      if not cmd:sub(i, i):match("%w") and saw_letter then
        break
      end
      vim.fn.setcmdpos(i + 1)
    end
  end
  return cmd
end

function M.init()
  vim.keymap.set("c", "<C-a>", "<Home>")
  vim.keymap.set("c", "<C-b>", "<Left>")
  vim.keymap.set("c", "<C-d>", "<Delete>")
  vim.keymap.set("c", "<C-e>", "<End>")
  vim.keymap.set("c", "<C-f>", "<Right>")
  vim.keymap.set("c", "<C-g>", "<C-c>")
  vim.keymap.set("c", "<C-n>", "<Down>")
  vim.keymap.set("c", "<C-p>", "<Up>")
  local expr = [[<C-\>e luaeval("require('commandline').%s()")<CR>]]
  vim.keymap.set("c", "<C-k>", expr:format("kill_line"))
  vim.keymap.set("c", "<M-d>", expr:format("delete_word"))
  vim.keymap.set("c", "<M-b>", expr:format("bwd_by_word"))
  vim.keymap.set("c", "<M-f>", expr:format("fwd_by_word"))
end

return M
