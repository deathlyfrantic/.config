" Copyright © 2016 Zandr Martin
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
let g:colors_name = 'nihil'

if !has('gui_running') && !((&termguicolors) || (has('nvim') && $NVIM_TUI_ENABLE_TRUE_COLOR))
  if &t_Co < 256
    echoe 'The ' . g:colors_name . ' colorscheme requires a 256-color terminal or true-color Vim (Neovim or Gvim).'
    finish
  endif
endif

highlight clear

if exists('syntax_on')
    syntax reset
endif

if &background == 'dark'
  highlight Normal       ctermfg=249  ctermbg=16   cterm=NONE guifg=#b2b2b2 guibg=#000000 gui=NONE
  highlight Visual       ctermfg=16   ctermbg=249  cterm=NONE guifg=#000000 guibg=#b2b2b2 gui=NONE
  highlight Cursorline   ctermfg=NONE ctermbg=234  cterm=NONE guifg=NONE    guibg=#1c1c1c gui=NONE
  highlight CursorLineNr ctermfg=249  ctermbg=234  cterm=NONE guifg=#b2b2b2 guibg=#1c1c1c gui=NONE
  highlight StatusLine   ctermfg=16   ctermbg=245  cterm=NONE guifg=#000000 guibg=#8a8a8a gui=NONE
  highlight StatusLineNC ctermfg=16   ctermbg=238  cterm=NONE guifg=#000000 guibg=#444444 gui=NONE
  highlight LineNr       ctermfg=238  ctermbg=NONE cterm=NONE guifg=#444444 guibg=NONE    gui=NONE
  highlight VertSplit    ctermfg=238  ctermbg=NONE cterm=NONE guifg=#444444 guibg=NONE    gui=NONE
  highlight Comment      ctermfg=238  ctermbg=NONE cterm=NONE guifg=#444444 guibg=NONE    gui=NONE
  highlight MatchParen   ctermfg=231  ctermbg=NONE cterm=bold guifg=#ffffff guibg=NONE    gui=bold
  highlight String       ctermfg=244  ctermbg=NONE cterm=NONE guifg=#808080 guibg=NONE    gui=NONE
else
  highlight Normal       ctermfg=16   ctermbg=255  cterm=NONE guifg=#000000 guibg=#eeeeee gui=NONE
  highlight Visual       ctermfg=255  ctermbg=16   cterm=NONE guifg=#eeeeee guibg=#000000 gui=NONE
  highlight Cursorline   ctermfg=NONE ctermbg=253  cterm=NONE guifg=NONE    guibg=#dadada gui=NONE
  highlight CursorLineNr ctermfg=16   ctermbg=253  cterm=NONE guifg=#000000 guibg=#dadada gui=NONE
  highlight StatusLine   ctermfg=255  ctermbg=16   cterm=NONE guifg=#eeeeee guibg=#000000 gui=NONE
  highlight StatusLineNC ctermfg=255  ctermbg=238  cterm=NONE guifg=#eeeeee guibg=#444444 gui=NONE
  highlight LineNr       ctermfg=246  ctermbg=NONE cterm=NONE guifg=#949494 guibg=NONE    gui=NONE
  highlight VertSplit    ctermfg=16   ctermbg=NONE cterm=NONE guifg=#000000 guibg=NONE    gui=NONE
  highlight Comment      ctermfg=246  ctermbg=NONE cterm=NONE guifg=#949494 guibg=NONE    gui=NONE
  highlight MatchParen   ctermfg=25   ctermbg=NONE cterm=bold guifg=#005fff guibg=NONE    gui=bold
  highlight String       ctermfg=239  ctermbg=NONE cterm=NONE guifg=#4e4e4e guibg=NONE    gui=NONE
endif

highlight PmenuSbar             ctermfg=244  ctermbg=240  cterm=NONE           guifg=#808080 guibg=#585858 gui=NONE
highlight PmenuThumb            ctermfg=NONE ctermbg=249  cterm=NONE           guifg=NONE    guibg=#b2b2b2 gui=NONE
highlight Error                 ctermfg=196  ctermbg=NONE cterm=NONE           guifg=#ff0000 guibg=NONE    gui=NONE
highlight SpellBad              ctermfg=196  ctermbg=NONE cterm=underline      guifg=#ff0000 guibg=NONE    gui=underline
highlight SpellCap              ctermfg=202  ctermbg=NONE cterm=underline      guifg=#ff5f00 guibg=NONE    gui=underline
highlight Search                ctermfg=231  ctermbg=25   cterm=NONE           guifg=#ffffff guibg=#005fff gui=NONE
highlight TODO                  ctermfg=202  ctermbg=NONE cterm=bold,underline guifg=#ff5f00 guibg=NONE    gui=bold,underline
highlight DiffAdd               ctermfg=46   ctermbg=28   cterm=NONE           guifg=#00ff00 guibg=#008700 gui=NONE
highlight DiffChange            ctermfg=226  ctermbg=100  cterm=NONE           guifg=#ffff00 guibg=#878700 gui=NONE
highlight DiffText              ctermfg=226  ctermbg=100  cterm=underline      guifg=#ffff00 guibg=#878700 gui=underline
highlight DiffDelete            ctermfg=196  ctermbg=88   cterm=NONE           guifg=#ff0000 guibg=#870000 gui=NONE
highlight WarningMsg            ctermfg=226  ctermbg=NONE cterm=NONE           guifg=#ffff00 guibg=NONE    gui=NONE
highlight GitGutterAdd          ctermfg=46   ctermbg=NONE cterm=NONE           guifg=#00ff00 guibg=NONE    gui=NONE
highlight GitGutterChangeDelete ctermfg=202  ctermbg=NONE cterm=NONE           guifg=#ff5f00 guibg=NONE    gui=NONE

highlight! link NeomakeWarningSign    WarningMsg
highlight! link NeomakeErrorSign      Error
highlight! link GitGutterChange       WarningMsg
highlight! link ErrorMsg              Error
highlight! link GitGutterDelete       Error
highlight! link CursorColumn          CursorLine
highlight! link ColorColumn           CursorLine
highlight! link WildMenu              Normal
highlight! link Pmenu                 StatusLine
highlight! link PmenuSel              WildMenu
highlight! link SignColumn            LineNr
highlight! link FoldColumn            LineNr
highlight! link Folded                LineNr
highlight! link TabLine               StatusLine
highlight! link TabLineSel            WildMenu
highlight! link TabLineFill           StatusLine
highlight! link TabLineClose          WildMenu
highlight! link CtrlPMode1            StatusLine
highlight! link CtrlPMode2            StatusLine
highlight! link Directory             Normal
highlight! link Underlined            Normal
highlight! link Question              Normal
highlight! link MoreMsg               Normal
highlight! link ModeMsg               Normal
highlight! link SpecialKey            Normal
highlight! link NonText               Comment
highlight! link Conceal               Comment
highlight! link phpDocTags            Comment
highlight! link SpellRare             Normal
highlight! link SpellLocal            Normal
highlight! link Boolean               Normal
highlight! link Constant              Normal
highlight! link Special               Normal
highlight! link Identifier            Normal
highlight! link Statement             Normal
highlight! link PreProc               Normal
highlight! link Type                  Normal
highlight! link Define                Normal
highlight! link Number                Normal
highlight! link gitcommitOverflow     Error
highlight! link Function              Normal
highlight! link Include               Normal
highlight! link PreCondit             Normal
highlight! link Keyword               Normal
highlight! link Title                 Normal
highlight! link Delimiter             Normal
highlight! link StorageClass          Normal
highlight! link Operator              Normal
highlight! link IncSearch             Search
highlight! link SneakPluginTarget     Search
" vim: foldmethod=marker
