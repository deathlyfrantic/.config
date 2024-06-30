-- based on https://github.com/ap/vim-buftabline
local M = {}

---@return number[]
function M.user_buffers()
  local ret = vim.tbl_filter(function(buf)
    return vim.bo[buf].buflisted
      and not vim.list_contains({ "quickfix", "tree" }, vim.bo[buf].buftype)
  end, vim.api.nvim_list_bufs())
  table.sort(ret)
  return ret
end

---@param buf number
---@return boolean
function M.buf_in_window(buf)
  return vim.iter(vim.api.nvim_list_wins()):any(function(win)
    return vim.api.nvim_win_get_buf(win) == buf
  end)
end

---@param tab Tab
---@return string
function M.highlight_for(tab)
  return (tab.current and "TabLineSel")
    or (tab.in_window and "TabLineActive")
    or "TabLine"
end

---@param tabs Tab[]
local function populate_labels(tabs)
  -- populate `tab.pieces`, a temporary attribute used to generate labels
  local labels = vim
    .iter(tabs)
    :map(function(tab)
      tab.pieces = tab.name:split("/", { trimempty = false })
      tab.label = tab.pieces[#tab.pieces]
      return tab
    end)
    -- fold the tabs into a table with the potential label as the key
    :fold(
      {},
      function(acc, tab)
        local label = tab.pieces[#tab.pieces]
        if not acc[label] then
          acc[label] = {}
        end
        table.insert(acc[label], tab)
        return acc
      end
    )
  -- disambiguate the labels, e.g. if two buffers represent files named
  -- "foo.txt", they get labeled as "bar/foo.txt" and "baz/foo.txt"
  for potential_label, tabs_with_label in pairs(labels) do
    if #tabs_with_label < 2 then
      tabs_with_label[1].label = potential_label
    else
      while true do
        local new_tabs = {}
        for _, tab in ipairs(tabs_with_label) do
          if #tab.pieces == 1 then
            tab.label = tab.pieces[1]
          else
            local last_piece = table.remove(tab.pieces)
            local penultimate = table.remove(tab.pieces)
            local label = penultimate and (penultimate .. "/" .. last_piece)
              or last_piece
            tab.label = label
            table.insert(tab.pieces, label)
          end
          if not new_tabs[tab.label] then
            new_tabs[tab.label] = {}
          end
          table.insert(new_tabs[tab.label], tab)
        end
        if
          vim.iter(new_tabs):all(function(key, value)
            return #value == 1 or key == ""
          end)
        then
          -- we have one label per tab so we're done
          break
        end
      end
    end
  end
  -- remove the `pieces` list from each tab as we no longer need it
  vim.iter(tabs):each(function(tab)
    tab.pieces = nil
  end)
end

---@return Tab[]
function M.get_tabs()
  local current_buf = vim.api.nvim_get_current_buf()
  local tabs = vim.tbl_map(function(buf_num)
    ---@class Tab
    ---@field buf number
    ---@field type string
    ---@field name string
    ---@field modified boolean
    ---@field current boolean
    ---@field label string
    ---@field in_window boolean
    ---@field width number
    return {
      buf = buf_num,
      type = vim.bo[buf_num].buftype,
      name = vim.api.nvim_buf_get_name(buf_num),
      modified = vim.bo[buf_num].modified,
      current = buf_num == current_buf,
      in_window = M.buf_in_window(buf_num),
      width = 0,
    }
  end, M.user_buffers())
  populate_labels(tabs)
  -- add modified indicator and tab number
  for i, tab in ipairs(tabs) do
    tab.label = ("%s%s %s"):format(
      tab.modified and "+" or "",
      i,
      tab.label:is_empty() and "[No name]" or tab.label
    )
  end
  return tabs
end

-- Create the tabline, keeping the current buffer in the center of the screen as
-- much as possible.
---@return string
function M.render()
  local tabs = M.get_tabs()
  local left = {
    last_tab = function()
      return tabs[1]
    end,
    remove_last_tab = function()
      return table.remove(tabs, 1)
    end,
    cut = function(label, replacement)
      return replacement .. label:sub(2)
    end,
    indicator = "<",
    width = 0,
    half = vim.o.columns / 2,
  }
  local right = {
    last_tab = function()
      return tabs[#tabs]
    end,
    remove_last_tab = function()
      return table.remove(tabs)
    end,
    cut = function(label, replacement)
      return label:sub(1, -2) .. replacement
    end,
    indicator = ">",
    width = 0,
    half = vim.o.columns / 2,
  }
  -- sum the string lengths for the left and right halves
  local current_side = left
  for _, tab in ipairs(tabs) do
    tab.width = #tab.label + 2 -- to account for padding
    tab.label = " " .. vim.fn.strtrans(tab.label):gsub("%%", "%%%%") .. " "
    if tab.current then
      left.width = left.width + (tab.width / 2)
      right.width = right.width + tab.width - (tab.width / 2)
      current_side = right
    else
      current_side.width = current_side.width + tab.width
    end
  end
  if current_side == left then -- centered buffer not seen?
    -- then blame any overflow on the right side, to protect the left
    right.width = left.width
    left.width = 0
  end
  -- toss away tabs and pieces until all fits
  if left.width + right.width > vim.o.columns then
    local oversized = (
      left.width < left.half and { { right, vim.o.columns - left.width } }
    )
      or (right.width < right.half and { { left, vim.o.columns - right.width } })
      or { { left, left.half }, { right, right.half } }
    for _, oversize in ipairs(oversized) do
      local side, budget = unpack(oversize)
      local delta = side.width - budget
      -- toss entire tabs to close the distance
      while delta >= side.last_tab().width do
        delta = delta - side.remove_last_tab().width
      end
      -- then snip at the last one to make it fit
      local end_tab = side.last_tab()
      while delta > end_tab.width - #end_tab.label do
        end_tab.label = side.cut(end_tab.label, "")
      end
      end_tab.label = side.cut(end_tab.label, side.indicator)
    end
  end
  return vim
    .iter(tabs)
    :map(function(tab)
      return ("%%#%s#%s"):format(M.highlight_for(tab), tab.label)
    end)
    :join("") .. "%#TabLineFill#"
end

---@param zombie? number
local function update(zombie)
  -- account for BufDelete triggering before buffer is actually deleted
  local bufs = vim.tbl_filter(function(buf)
    return buf ~= zombie
  end, M.user_buffers())
  vim.o.showtabline = #bufs > 1 and 2 or 1
  vim.o.tabline = "%!v:lua.require'tabline'.render()"
end

function M.init()
  local augroup = vim.api.nvim_create_augroup("tabline", {})
  vim.api.nvim_create_autocmd({ "VimEnter", "TabEnter", "BufAdd" }, {
    pattern = "*",
    callback = update,
    group = augroup,
  })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = update,
    group = augroup,
  })
  vim.api.nvim_create_autocmd("BufDelete", {
    pattern = "*",
    callback = function(args)
      update(args.buf)
    end,
    group = augroup,
  })
  for i, k in ("1234567890qwertyuiop"):chars() do
    vim.keymap.set("n", "<M-" .. k .. ">", function()
      local bufs = M.user_buffers()
      if i <= #bufs then
        vim.api.nvim_set_current_buf(bufs[i])
      end
    end, { silent = true })
  end
end

return M
