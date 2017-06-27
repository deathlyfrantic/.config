" Copyright © 2017 Zandr Martin
"
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the "Software"),
" to deal in the Software without restriction, including without limitation
" the rights to use, copy, modify, merge, publish, distribute, sublicense,
" and/or sell copies of the Software, and to permit persons to whom the
" Software is furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included
" in all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
" OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
" IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
" DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
" TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
" OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
if !has('gui_running') && !((&termguicolors) || (has('nvim') && $NVIM_TUI_ENABLE_TRUE_COLOR))
  if &t_Co < 256
    echoerr 'The dosedit colorscheme requires a 256-color terminal or true-color Vim (Neovim or Gvim).'
    finish
  endif
endif

highlight clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'dosedit'

highlight Normal                ctermfg=251  ctermbg=18   cterm=NONE           guifg=#c6c6c6 guibg=#000087 gui=NONE
highlight Visual                ctermfg=16   ctermbg=251  cterm=NONE           guifg=#000000 guibg=#c6c6c6 gui=NONE
highlight Cursorline            ctermfg=NONE ctermbg=19   cterm=NONE           guifg=NONE    guibg=#0000af gui=NONE
highlight CursorLineNr          ctermfg=NONE ctermbg=19   cterm=NONE           guifg=NONE    guibg=#0000af gui=NONE
highlight StatusLine            ctermfg=16   ctermbg=248  cterm=NONE           guifg=#000000 guibg=#a8a8a8 gui=NONE
highlight StatusLineNC          ctermfg=16   ctermbg=241  cterm=NONE           guifg=#000000 guibg=#606060 gui=NONE
highlight LineNr                ctermfg=60   ctermbg=NONE cterm=NONE           guifg=#5f5f87 guibg=NONE    gui=NONE
highlight VertSplit             ctermfg=248  ctermbg=16   cterm=NONE           guifg=#a8a8a8 guibg=#000000 gui=NONE
highlight String                ctermfg=103  ctermbg=NONE cterm=NONE           guifg=#8787af guibg=NONE    gui=NONE
highlight WarningMsg            ctermfg=226  ctermbg=NONE cterm=NONE           guifg=#ffff00 guibg=NONE    gui=NONE
highlight GitGutterAdd          ctermfg=46   ctermbg=NONE cterm=NONE           guifg=#00ff00 guibg=NONE    gui=NONE
highlight MatchParen            ctermfg=46   ctermbg=NONE cterm=bold           guifg=#00ff00 guibg=NONE    gui=bold
highlight WildMenu              ctermfg=248  ctermbg=16   cterm=NONE           guifg=#a8a8a8 guibg=#000000 gui=NONE
highlight PmenuSbar             ctermfg=244  ctermbg=240  cterm=NONE           guifg=#808080 guibg=#585858 gui=NONE
highlight PmenuThumb            ctermfg=NONE ctermbg=231  cterm=NONE           guifg=NONE    guibg=#a8a8a8 gui=NONE
highlight Error                 ctermfg=196  ctermbg=NONE cterm=NONE           guifg=#ff0000 guibg=NONE    gui=NONE
highlight SpellBad              ctermfg=196  ctermbg=NONE cterm=underline      guifg=#ff0000 guibg=NONE    gui=underline
highlight SpellCap              ctermfg=202  ctermbg=NONE cterm=underline      guifg=#ff5f00 guibg=NONE    gui=underline
highlight Search                ctermfg=231  ctermbg=127  cterm=NONE           guifg=#ffffff guibg=#af00af gui=NONE
highlight TODO                  ctermfg=202  ctermbg=NONE cterm=bold,underline guifg=#ff5f00 guibg=NONE    gui=bold,underline
highlight DiffAdd               ctermfg=46   ctermbg=28   cterm=NONE           guifg=#00ff00 guibg=#008700 gui=NONE
highlight DiffChange            ctermfg=226  ctermbg=NONE cterm=NONE           guifg=#ffff00 guibg=NONE    gui=NONE
highlight DiffText              ctermfg=226  ctermbg=100  cterm=NONE           guifg=#ffff00 guibg=#878700 gui=NONE
highlight DiffDelete            ctermfg=196  ctermbg=88   cterm=NONE           guifg=#ff0000 guibg=#870000 gui=NONE
highlight GitGutterChangeDelete ctermfg=202  ctermbg=NONE cterm=NONE           guifg=#ff5f00 guibg=NONE    gui=NONE
highlight TabLineSel            ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight TabLineClose          ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Directory             ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Underlined            ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Question              ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight MoreMsg               ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight ModeMsg               ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight SpellRare             ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight SpellLocal            ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Boolean               ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Constant              ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Special               ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Identifier            ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Statement             ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight PreProc               ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Type                  ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Define                ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Number                ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Function              ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Include               ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight PreCondit             ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Keyword               ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Title                 ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Delimiter             ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight StorageClass          ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight Operator              ctermfg=NONE ctermbg=NONE cterm=NONE           guifg=NONE    guibg=NONE    gui=NONE
highlight! link Comment               LineNr
highlight! link NeomakeWarningSign    WarningMsg
highlight! link NeomakeErrorSign      Error
highlight! link GitGutterChange       WarningMsg
highlight! link ErrorMsg              Error
highlight! link GitGutterDelete       Error
highlight! link CursorColumn          CursorLine
highlight! link ColorColumn           CursorLine
highlight! link Pmenu                 StatusLine
highlight! link PmenuSel              WildMenu
highlight! link SignColumn            LineNr
highlight! link FoldColumn            LineNr
highlight! link Folded                LineNr
highlight! link TabLine               StatusLine
highlight! link TabLineFill           StatusLine
highlight! link BufTabLineActive      StatusLine
highlight! link BufTabLineCurrent     TabLineSel
highlight! link BufTabLineHidden      StatusLine
highlight! link BufTabLineFill        StatusLine
highlight! link CtrlPMode1            StatusLine
highlight! link CtrlPMode2            StatusLine
highlight! link SpecialKey            Comment
highlight! link NonText               Comment
highlight! link Conceal               Comment
highlight! link phpDocTags            Comment
highlight! link IncSearch             Search
highlight! link gitcommitOverflow     Error
highlight! link SneakPluginTarget     Search
highlight! link diffAdded             DiffAdd
highlight! link diffRemoved           DiffDelete
