local M = {}

---@param name string
---@param termguicolors boolean
local function preamble(name, termguicolors)
  vim.o.termguicolors = termguicolors
  vim.cmd.highlight("clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd.syntax("reset")
  end
  vim.g.colors_name = name
end

---@param t table
local function highlight(t)
  for k, v in pairs(t) do
    vim.api.nvim_set_hl(0, k, v)
  end
end

local function clear_highlights()
  local no_highlights = {
    "Directory",
    "Underlined",
    "Question",
    "MoreMsg",
    "ModeMsg",
    "SpellRare",
    "SpellLocal",
    "Boolean",
    "Constant",
    "Special",
    "Identifier",
    "Statement",
    "PreProc",
    "Type",
    "Define",
    "Function",
    "Include",
    "PreCondit",
    "Keyword",
    "Title",
    "Delimiter",
    "StorageClass",
    "Operator",
    "@variable",
    "@markup",
    "DiagnosticFloatingOk",
    "DiagnosticFloatingWarn",
    "DiagnosticFloatingError",
    "DiagnosticFloatingHint",
    "DiagnosticFloatingInfo",
    "@number.diff",
  }
  vim.list_extend(no_highlights, vim.fn.getcompletion("@lsp", "highlight"))
  for _, group in ipairs(no_highlights) do
    vim.api.nvim_set_hl(0, group, {})
  end
end

local function set_links()
  local links = {
    WildMenu = "Search",
    GitSignsAdd = "Success",
    GitSignsChange = "Warning",
    GitSignsDelete = "Error",
    ALEWarningSign = "Warning",
    ALEErrorSign = "Warning",
    ALEInfoSign = "Success",
    ALEWarning = "SpellCap",
    ALEError = "SpellBad",
    ALEVirtualTextWarning = "Warning",
    ALEVirtualTextError = "Error",
    CursorColumn = "CursorLine",
    ColorColumn = "CursorLine",
    PmenuSel = "WildMenu",
    SignColumn = "LineNr",
    FoldColumn = "LineNr",
    Folded = "LineNr",
    TabLine = "StatusLine",
    TabLineFill = "TabLine",
    TabLineSel = "Normal",
    SpecialKey = "LineNr",
    NonText = "LineNr",
    Conceal = "Comment",
    rustAttribute = "Comment",
    rustDerive = "Comment",
    rustDeriveTrait = "Comment",
    rustCommentLineDoc = "Comment",
    IncSearch = "Search",
    gitcommitOverflow = "Error",
    diffAdded = "DiffAdd",
    diffRemoved = "DiffDelete",
    mailQuoted1 = "String",
    mailQuoted2 = "Comment",
    pythonDocString = "Comment",
    TagbarVisibilityProtected = "Warning",
    TagbarVisibilityPublic = "Success",
    TagbarVisibilityPrivate = "Error",
    Whitespace = "Comment",
    healthSuccess = "Success",
    healthWarning = "Warning",
    rustCharacter = "String",
    NvimInternalError = "Error",
    FloatBorder = "StatusLine",
    DiagnosticInfo = "LineNr",
    DiagnosticError = "Error",
    DiagnosticWarn = "Warning",
    DiagnosticOk = "Success",
    DiagnosticHint = "LineNr",
    ["@gitcommit_error"] = "Error",
    ["@error.json"] = "Error",
    ["@text.diff.add"] = "DiffAdd",
    ["@text.diff.delete"] = "DiffDelete",
    ["@field.yaml"] = "Normal",
    ["@diff.plus"] = "DiffAdd",
    ["@diff.minus"] = "DiffDelete",
    CurSearch = "Search",
    QuickFixLine = "Search",
    Added = "Success",
    Changed = "Warning",
    Removed = "Error",
    FloatShadow = "CursorLine",
    FloatShadowThrough = "CursorLine",
    NormalFloat = "Pmenu",
    makeCommands = "Normal",
    gitDate = "Normal",
  }
  for k, v in pairs(links) do
    vim.api.nvim_set_hl(0, k, { link = v })
  end
end

local function set_term_colors()
  -- tango scheme for terminal colors
  vim.g.terminal_color_0 = "#2e3436"
  vim.g.terminal_color_1 = "#cc0000"
  vim.g.terminal_color_2 = "#4e9a06"
  vim.g.terminal_color_3 = "#c4a000"
  vim.g.terminal_color_4 = "#3465a4"
  vim.g.terminal_color_5 = "#75507b"
  vim.g.terminal_color_6 = "#0b939b"
  vim.g.terminal_color_7 = "#d3d7cf"
  vim.g.terminal_color_8 = "#555753"
  vim.g.terminal_color_9 = "#ef2929"
  vim.g.terminal_color_10 = "#8ae234"
  vim.g.terminal_color_11 = "#fce94f"
  vim.g.terminal_color_12 = "#729fcf"
  vim.g.terminal_color_13 = "#ad7fa8"
  vim.g.terminal_color_14 = "#00f5e9"
  vim.g.terminal_color_15 = "#eeeeec"
end

---@param colors table
local function popup_window_namespace(colors)
  local ns_id = vim.api.nvim_create_namespace("popup-window")
  vim.api.nvim_set_hl(ns_id, "Normal", colors.Normal)
  vim.api.nvim_set_hl(ns_id, "FloatBorder", colors.Normal)
end

---@param name string
---@param termguicolors boolean
---@param colors table
function M.define(name, termguicolors, colors)
  preamble(name, termguicolors)
  highlight(colors)
  clear_highlights()
  set_links()
  if termguicolors then
    set_term_colors()
  end
  popup_window_namespace(colors)
end

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local links = {
      Warning = "WarningMsg",
    }
    for k, v in pairs(links) do
      if vim.tbl_count(vim.api.nvim_get_hl(0, { name = k })) == 0 then
        vim.api.nvim_set_hl(0, k, vim.api.nvim_get_hl(0, { name = v }))
      end
    end
  end,
  group = vim.api.nvim_create_augroup("color-groups-set", {}),
})

return M
