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
highlight! link rustAttribute             Comment
highlight! link rustDerive                Comment
highlight! link rustDeriveTrait           Comment
highlight! link rustCommentLineDoc        Comment
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
highlight! link NvimInternalError         Error
highlight! link FloatBorder               StatusLine

if &termguicolors
  " tango scheme for terminal colors
  let g:terminal_color_0  = '#2e3436'
  let g:terminal_color_1  = '#cc0000'
  let g:terminal_color_2  = '#4e9a06'
  let g:terminal_color_3  = '#c4a000'
  let g:terminal_color_4  = '#3465a4'
  let g:terminal_color_5  = '#75507b'
  let g:terminal_color_6  = '#0b939b'
  let g:terminal_color_7  = '#d3d7cf'
  let g:terminal_color_8  = '#555753'
  let g:terminal_color_9  = '#ef2929'
  let g:terminal_color_10 = '#8ae234'
  let g:terminal_color_11 = '#fce94f'
  let g:terminal_color_12 = '#729fcf'
  let g:terminal_color_13 = '#ad7fa8'
  let g:terminal_color_14 = '#00f5e9'
  let g:terminal_color_15 = '#eeeeec'
endif
