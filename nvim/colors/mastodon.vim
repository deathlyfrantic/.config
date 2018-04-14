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
  echoerr 'The mastodon colorscheme requires a true-color Vim (Neovim or Gvim).'
  finish
endif

highlight clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'mastodon'

highlight Normal                guifg=#c4c8d2 guibg=#282c37 gui=NONE           cterm=NONE           term=NONE
highlight Visual                guifg=NONE    guibg=#191b22 gui=NONE           cterm=NONE           term=NONE
highlight CursorLine            guifg=NONE    guibg=#30343f gui=NONE           cterm=NONE           term=NONE
highlight CursorLineNr          guifg=#9baec8 guibg=#30343f gui=NONE           cterm=NONE           term=NONE
highlight LineNr                guifg=#4c5269 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight StatusLine            guifg=#c4c8d2 guibg=#444b5d gui=NONE           cterm=NONE           term=NONE
highlight StatusLineNC          guifg=#444b5d guibg=#191b22 gui=NONE           cterm=NONE           term=NONE
highlight VertSplit             guifg=#191b22 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Comment               guifg=#606984 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight String                guifg=#9ca7c9 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight MatchParen            guifg=#ff7722 guibg=NONE    gui=bold           cterm=NONE           term=NONE
highlight Pmenu                 guifg=#c4c8d2 guibg=#444b5d gui=NONE           cterm=NONE           term=NONE
highlight PmenuSbar             guifg=#707b97 guibg=#707b97 gui=NONE           cterm=NONE           term=NONE
highlight PmenuThumb            guifg=NONE    guibg=#3b434e gui=NONE           cterm=NONE           term=NONE
highlight Error                 guifg=#f50039 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight SpellBad              guifg=#f50039 guibg=NONE    gui=underline      cterm=underline      term=underline
highlight SpellCap              guifg=#ff7722 guibg=NONE    gui=underline      cterm=underline      term=underline
highlight Search                guifg=#ffffff guibg=#1f72ad gui=NONE           cterm=NONE           term=NONE
highlight TODO                  guifg=#ff7722 guibg=NONE    gui=bold,underline cterm=bold,underline term=bold,underline
highlight DiffAdd               guifg=#00f57a guibg=#006633 gui=NONE           cterm=NONE           term=NONE
highlight DiffChange            guifg=#e2e212 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight DiffText              guifg=#e2e212 guibg=#636303 gui=NONE           cterm=NONE           term=NONE
highlight DiffDelete            guifg=#f50039 guibg=#80001e gui=NONE           cterm=NONE           term=NONE
highlight GitGutterChange       guifg=#ff7722 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight GitGutterAdd          guifg=#00f57a guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight GitGutterChangeDelete guifg=#ff7722 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight ErrorMsg              guifg=#ffffff guibg=#f50039 gui=bold           cterm=bold           term=bold
highlight WarningMsg            guifg=#ffffff guibg=#ff7722 gui=bold           cterm=bold           term=bold
highlight BufTabLineActive      guifg=#9ca7c9 guibg=#444b5d gui=NONE           cterm=NONE           term=NONE
highlight TermCursorNC          guifg=#000000 guibg=#606984 gui=NONE           cterm=NONE           term=NONE

highlight TabLineSel   NONE
highlight TabLineClose NONE
highlight Directory    NONE
highlight Underlined   NONE
highlight Question     NONE
highlight MoreMsg      NONE
highlight ModeMsg      NONE
highlight SpellRare    NONE
highlight SpellLocal   NONE
highlight Boolean      NONE
highlight Constant     NONE
highlight Special      NONE
highlight Identifier   NONE
highlight Statement    NONE
highlight PreProc      NONE
highlight Type         NONE
highlight Define       NONE
highlight Number       NONE
highlight Function     NONE
highlight Include      NONE
highlight PreCondit    NONE
highlight Keyword      NONE
highlight Title        NONE
highlight Delimiter    NONE
highlight StorageClass NONE
highlight Operator     NONE

highlight! link TabLine                   StatusLine
highlight! link WildMenu                  Search
highlight! link GitGutterDelete           Error
highlight! link NeomakeWarningSign        GitGutterChange
highlight! link NeomakeErrorSign          Error
highlight! link NeomakeInfoSign           GitGutterChangeLine
highlight! link NeomakeMessageSign        GitGutterAdd
highlight! link ALEWarningSign            GitGutterChange
highlight! link ALEErrorSign              GitGutterChange
highlight! link ALEInfoSign               GitGutterChangeLine
highlight! link TermCursor                Cursor
highlight! link CursorColumn              CursorLine
highlight! link ColorColumn               CursorLine
highlight! link PmenuSel                  WildMenu
highlight! link SignColumn                LineNr
highlight! link FoldColumn                LineNr
highlight! link Folded                    LineNr
highlight! link TabLineFill               TabLine
highlight! link BufTabLineCurrent         Normal
highlight! link BufTabLineHidden          TabLine
highlight! link BufTabLineFill            TabLine
highlight! link CtrlPMode1                StatusLine
highlight! link CtrlPMode2                StatusLine
highlight! link CtrlPMatch                String
highlight! link SpecialKey                LineNr
highlight! link NonText                   LineNr
highlight! link Conceal                   Comment
highlight! link phpDocTags                Comment
highlight! link rustAttribute             Comment
highlight! link rustDerive                Comment
highlight! link rustDeriveTrait           Comment
highlight! link IncSearch                 Search
highlight! link gitcommitOverflow         Error
highlight! link Sneak                     Search
highlight! link diffAdded                 DiffAdd
highlight! link diffRemoved               DiffDelete
highlight! link mailQuoted1               String
highlight! link mailQuoted2               Comment
highlight! link pythonDocString           Comment
highlight! link TagbarVisibilityProtected GitGutterChange
highlight! link TagbarVisibilityPublic    GitGutterAdd
highlight! link TagbarVisibilityPrivate   GitGutterDelete
highlight! link Whitespace                Comment
highlight! link SignifySignAdd            GitGutterAdd
highlight! link SignifySignChange         GitGutterChange
highlight! link SignifySignDelete         GitGutterDelete
highlight! link healthSuccess             GitGutterAdd
highlight! link healthWarning             GitGutterChange
highlight! link rustCharacter             String
