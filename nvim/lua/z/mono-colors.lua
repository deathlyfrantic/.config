local function preamble(name, termguicolors)
  vim.o.termguicolors = termguicolors
  vim.cmd.highlight("clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd.syntax("reset")
  end
  vim.g.colors_name = name
end

local function highlight(t)
  for k, v in pairs(t) do
    vim.api.nvim_set_hl(0, k, v)
  end
end

local function clear_highlights()
  local no_highlights = {
    "TabLineSel",
    "TabLineClose",
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
    "Number",
    "Function",
    "Include",
    "PreCondit",
    "Keyword",
    "Title",
    "Delimiter",
    "StorageClass",
    "Operator",
  }

  for _, group in ipairs(no_highlights) do
    vim.api.nvim_set_hl(0, group, {})
  end
end

local function set_links()
  local links = {
    TabLine = "StatusLine",
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
    TabLineFill = "TabLine",
    BufTabLineCurrent = "Normal",
    BufTabLineHidden = "TabLine",
    BufTabLineFill = "TabLine",
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
    ["@gitcommit_error"] = "Error",
    ["@error.json"] = "Error",
    ["@text.diff.add"] = "DiffAdd",
    ["@text.diff.delete"] = "DiffDelete",
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

local function define(name, termguicolors, colors)
  preamble(name, termguicolors)
  highlight(colors)
  clear_highlights()
  set_links()
  if termguicolors then
    set_term_colors()
  end
end

return {
  define = define,
}
