local colors = {
  GitSignsAdd = { ctermfg = 34 },
  MatchParen = { ctermfg = 202, cterm = { bold = true } },
  WildMenu = { ctermfg = 255, ctermbg = 25 },
  PmenuSbar = { ctermfg = 244, ctermbg = 240 },
  PmenuThumb = { ctermbg = 249 },
  Error = { ctermfg = 196 },
  SpellBad = { ctermfg = 196, cterm = { underline = true } },
  SpellCap = { ctermfg = 202, cterm = { underline = true } },
  Search = { ctermfg = 231, ctermbg = 27 },
  TODO = { ctermfg = 202, cterm = { bold = true, underline = true } },
  DiffAdd = { ctermfg = 46, ctermbg = 28 },
  DiffChange = { ctermfg = 226 },
  DiffText = { ctermfg = 226, ctermbg = 100 },
  DiffDelete = { ctermfg = 196, ctermbg = 88 },
  GitSignsChangeDelete = { ctermfg = 202 },
  ErrorMsg = { ctermfg = 231, ctermbg = 196, cterm = { bold = true } },
  WarningMsg = { ctermfg = 231, ctermbg = 202, cterm = { bold = true } },
}

if vim.o.background == "dark" then
  colors = vim.tbl_extend("force", colors, {
    Normal = { ctermfg = 249, ctermbg = 16 },
    Visual = { ctermfg = 16, ctermbg = 249 },
    Cursorline = { ctermbg = 233 },
    CursorLineNr = { ctermfg = 249, ctermbg = 233 },
    StatusLine = { ctermfg = 16, ctermbg = 245 },
    StatusLineNC = { ctermfg = 16, ctermbg = 238 },
    LineNr = { ctermfg = 238 },
    VertSplit = { ctermfg = 238 },
    Comment = { ctermfg = 238 },
    String = { ctermfg = 244 },
    GitSignsChange = { ctermfg = 184 },
    BufTabLineActive = { ctermfg = 231, ctermbg = 245 },
  })
else
  colors = vim.tbl_extend("force", colors, {
    Normal = { ctermfg = 235, ctermbg = 251 },
    Visual = { ctermfg = 251, ctermbg = 235 },
    Cursorline = { ctermbg = 252 },
    CursorLineNr = { ctermfg = 235, ctermbg = 252 },
    StatusLine = { ctermfg = 251, ctermbg = 235 },
    StatusLineNC = { ctermfg = 251, ctermbg = 238 },
    LineNr = { ctermfg = 246 },
    VertSplit = { ctermfg = 235 },
    Comment = { ctermfg = 246 },
    String = { ctermfg = 239 },
    GitSignsChange = { ctermfg = 226 },
    BufTabLineActive = { ctermfg = 231, ctermbg = 235 },
  })
end

require("mono-colors").define("nihil", false, colors)
