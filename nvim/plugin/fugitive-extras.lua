-- this is a modified version of vim-fugitive-blame-ext by Tom McDonald
-- see: https://github.com/tommcdo/vim-fugitive-blame-ext
local api = vim.api
local z = require("z")

local subj_cmd = "git --git-dir=%s show -s --pretty=format:%%s %s"
local full_cmd = "git --git-dir=%s show -s --format=medium --color=never %s"
local popup_window

local function log_message(commit)
  if commit:match("^0+$") then
    return { subj = "(Not Committed Yet)", full = "" }
  end
  if not vim.b.blame_messages or not vim.b.blame_messages[commit] then
    local subj = io.popen(subj_cmd:format(vim.b.git_dir, commit)):read("*all")
    local full = io.popen(full_cmd:format(vim.b.git_dir, commit)):read("*all")
    -- can't insert a value into a vim.b table; have to reassign the whole thing
    vim.b.blame_messages = vim.tbl_extend(
      "force",
      vim.b.blame_messages or {},
      { [commit] = { subj = subj, full = full } }
    )
  end
  return vim.b.blame_messages[commit]
end

local function truncate_message(msg)
  local offset = 2
  if
    vim.o.ruler
    or (
      vim.o.laststatus == 0
      or (vim.o.laststatus == 1 and #api.nvim_list_wins() == 1)
    )
  then
    -- Statusline is not visible, so the ruler is. Its width is either 17
    -- (default) or defined in 'rulerformat'.
    local ruler_num = vim.o.rulerformat:match("^%%(%d+)%(") or 17
    offset = offset + 1 + ruler_num
  end
  if vim.o.showcmd then
    offset = offset + 11
  end
  local maxwidth = vim.o.columns - offset
  if #msg > maxwidth then
    return msg:sub(1, maxwidth - 3) .. "..."
  end
  return msg
end

local function get_commit_from_line()
  return api.nvim_get_current_line():match("^[0-9A-Fa-f]+")
end

local function show_log_message()
  local commit = get_commit_from_line()
  local blame = log_message(commit)
  api.nvim_echo({ { truncate_message(blame.subj) } }, false, {})
end

local function close_popup()
  if popup_window and api.nvim_win_is_valid(popup_window) then
    api.nvim_win_close(popup_window, true)
  end
  popup_window = nil
end

local function popup()
  close_popup()
  local commit = get_commit_from_line()
  local blame = log_message(commit)
  popup_window = z.popup(blame.full)
  api.nvim_create_autocmd({ "CursorMoved", "BufLeave", "BufWinLeave" }, {
    buffer = 0,
    callback = close_popup,
    once = true,
    group = api.nvim_create_augroup("fugitive-extras-popup", {}),
  })
end

_G.fugitive_extras = { popup = popup }

local group = api.nvim_create_augroup("fugitive-extras-blame", {})
api.nvim_create_autocmd("BufEnter", {
  pattern = "*.fugitiveblame",
  callback = function()
    -- needs to be separate and deferred otherwise it doesn't work ¯\_(ツ)_/¯
    vim.defer_fn(show_log_message, 100)
  end,
  group = group,
})
api.nvim_create_autocmd(
  "CursorMoved",
  { pattern = "*.fugitiveblame", callback = show_log_message, group = group }
)
api.nvim_create_autocmd("FileType", {
  pattern = "fugitiveblame",
  callback = function()
    api.nvim_buf_set_keymap(
      0,
      "n",
      "Q",
      "<Cmd>call v:lua.fugitive_extras.popup()<CR>",
      { noremap = true }
    )
  end,
  group = group,
})
