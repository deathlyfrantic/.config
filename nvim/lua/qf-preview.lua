local api = vim.api
local z = require("z")

local popup_window = -1

local function file_info()
  local filename, line, col = api.nvim_get_current_line():match("^(.+)|(%d+) col (%d+)|")
  if filename == nil then
    return nil
  end
  local ret = { filename = filename, line = tonumber(line) }
  if col ~= nil then
    ret.col = tonumber(col)
  end
  return ret
end

local function get_lines_and_pos(info)
  local previewheight = vim.o.previewheight or 12
  local context = previewheight / 2
  local lines = z.collect(
    io.open(info.filename):lines(),
    math.max(info.line + context, previewheight)
  )
  local line
  if #lines < (previewheight + 1) then
    line = info.line
  elseif #lines < (info.line + context) then
    local lines_after = #lines - info.line
    line = previewheight - lines_after + 2
    lines = vim.list_slice(lines, #lines - previewheight - 1)
  else
    line = context + 2
    lines = vim.list_slice(lines, #lines - previewheight - 1)
  end
  return lines, line
end

local function preview_contents(info)
  local lines, line = get_lines_and_pos(info)
  popup_window = z.popup(lines)
  local width = math.max(unpack(vim.tbl_map(string.len, lines)))
  api.nvim_buf_add_highlight(
    api.nvim_win_get_buf(popup_window),
    -1,
    "PmenuSel",
    line,
    1,
    width + 1
  )
end

local function close_popup()
  if vim.tbl_contains(api.nvim_list_wins(), popup_window) then
    api.nvim_win_close(popup_window, true)
  end
  popup_window = -1
end

local function _preview()
  close_popup()
  local info = file_info()
  if info ~= nil then
    preview_contents(info)
    vim.cmd([[autocmd CursorMoved,BufLeave,BufWinLeave <buffer> ++once lua require("qf-preview")._close_popup()]])
  end
end

local function init()
  vim.cmd([[
    augroup quickfix-preview
      autocmd FileType qf nnoremap <buffer> Q <Cmd>lua require("qf-preview")._preview()<CR>
    augroup END
  ]])
end

return {
  init = init,
  _close_popup = close_popup,
  _preview = _preview,
}
