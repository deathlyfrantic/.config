local z = require("z")
local set_keymap = vim.api.nvim_set_keymap

local function poscmd()
  return vim.fn.getcmdpos(), vim.fn.getcmdline()
end

local function kill_line()
  local pos, cmd = poscmd()
  if pos == 1 then
    return ""
  end
  return cmd:sub(1, pos - 1)
end

local function delete_word()
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

local function bwd_by_word()
  local pos, cmd = poscmd()
  if pos ~= 1 then
    local saw_letter = false
    local i = pos - 1
    while i > 0 do
      i = i - 1
      saw_letter = saw_letter or cmd:sub(i + 1, i + 1):match("%w") ~= nil
      if cmd:sub(i + 1, i + 1):match("%w") == nil and saw_letter then
        i = i + 1
        break
      end
      vim.fn.setcmdpos(i + 1)
    end
  end
  return cmd
end

local function fwd_by_word()
  local pos, cmd = poscmd()
  local cmdlen = #cmd
  if pos < cmdlen then
    local saw_letter = false
    local i = pos - 1
    while i < cmdlen do
      i = i + 1
      saw_letter = saw_letter or cmd:sub(i + 1, i + 1):match("%w") ~= nil
      if cmd:sub(i + 1, i + 1):match("%w") == nil and saw_letter then
        break
      end
      vim.fn.setcmdpos(i + 2)
    end
  end
  return cmd
end

local function call(fn)
  return ([[<C-\>e luaeval("commandline.%s()")<CR>]]):format(fn)
end

local function remap(left, right)
  set_keymap("c", left, right, {})
end

remap("<C-a>", "<Home>")
remap("<C-b>", "<Left>")
remap("<C-d>", "<Delete>")
remap("<C-e>", "<End>")
remap("<C-f>", "<Right>")
remap("<C-g>", "<C-c>")
remap("<C-n>", "<Down>")
remap("<C-p>", "<Up>")
remap("<C-k>", call("kill_line"))
remap("<M-d>", call("delete_word"))
set_keymap("c", "<M-b>", call("bwd_by_word"), {})
set_keymap("c", "<M-f>", call("fwd_by_word"), {})

_G.commandline = {
  kill_line = kill_line,
  bwd_by_word = bwd_by_word,
  fwd_by_word = fwd_by_word,
  delete_word = delete_word,
}
