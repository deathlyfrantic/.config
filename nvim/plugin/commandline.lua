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

vim.keymap.set("c", "<C-a>", "<Home>")
vim.keymap.set("c", "<C-b>", "<Left>")
vim.keymap.set("c", "<C-d>", "<Delete>")
vim.keymap.set("c", "<C-e>", "<End>")
vim.keymap.set("c", "<C-f>", "<Right>")
vim.keymap.set("c", "<C-g>", "<C-c>")
vim.keymap.set("c", "<C-n>", "<Down>")
vim.keymap.set("c", "<C-p>", "<Up>")
vim.keymap.set("c", "<C-k>", call("kill_line"))
vim.keymap.set("c", "<M-d>", call("delete_word"))
vim.keymap.set("c", "<M-b>", call("bwd_by_word"))
vim.keymap.set("c", "<M-f>", call("fwd_by_word"))

_G.commandline = {
  kill_line = kill_line,
  bwd_by_word = bwd_by_word,
  fwd_by_word = fwd_by_word,
  delete_word = delete_word,
}
