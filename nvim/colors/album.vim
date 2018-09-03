if &t_Co < 256
  echoerr 'The album colorscheme requires a 256-color Vim.'
  finish
endif

highlight clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'album'

highlight Normal                ctermfg=253  ctermbg=234  cterm=NONE
highlight NormalNC              ctermfg=250  ctermbg=NONE cterm=NONE
highlight Visual                ctermfg=NONE ctermbg=232  cterm=NONE
highlight CursorLine            ctermfg=NONE ctermbg=235  cterm=NONE
highlight CursorLineNr          ctermfg=240  ctermbg=235  cterm=NONE
highlight LineNr                ctermfg=238  ctermbg=NONE cterm=NONE
highlight StatusLine            ctermfg=253  ctermbg=65   cterm=NONE
highlight StatusLineNC          ctermfg=232  ctermbg=65   cterm=NONE
highlight VertSplit             ctermfg=232  ctermbg=NONE cterm=NONE
highlight Comment               ctermfg=240  ctermbg=NONE cterm=NONE
highlight String                ctermfg=247  ctermbg=NONE cterm=NONE
highlight MatchParen            ctermfg=215  ctermbg=236  cterm=bold
highlight Pmenu                 ctermfg=232  ctermbg=244  cterm=NONE
highlight PmenuSbar             ctermfg=246  ctermbg=246  cterm=NONE
highlight PmenuThumb            ctermfg=250  ctermbg=250  cterm=NONE
highlight Error                 ctermfg=231  ctermbg=197  cterm=NONE
highlight SpellBad              ctermfg=197  ctermbg=NONE cterm=underline
highlight SpellCap              ctermfg=215  ctermbg=NONE cterm=underline
highlight Search                ctermfg=232  ctermbg=114  cterm=bold
highlight TODO                  ctermfg=228  ctermbg=NONE cterm=bold,underline
highlight DiffAdd               ctermfg=120  ctermbg=29   cterm=NONE
highlight DiffChange            ctermfg=228  ctermbg=NONE cterm=NONE
highlight DiffText              ctermfg=228  ctermbg=101  cterm=NONE
highlight DiffDelete            ctermfg=197  ctermbg=88   cterm=NONE
highlight GitGutterAdd          ctermfg=120  ctermbg=NONE cterm=NONE
highlight GitGutterChange       ctermfg=215  ctermbg=NONE cterm=NONE
highlight GitGutterChangeDelete ctermfg=209  ctermbg=NONE cterm=NONE
highlight GitGutterDelete       ctermfg=197  ctermbg=NONE cterm=NONE
highlight ErrorMsg              ctermfg=231  ctermbg=197  cterm=bold
highlight WarningMsg            ctermfg=231  ctermbg=173  cterm=bold
highlight BufTabLineActive      ctermfg=253  ctermbg=65   cterm=NONE
highlight Cursor                ctermfg=bg   ctermbg=fg   cterm=NONE
highlight TermCursor            ctermfg=bg   ctermbg=fg   cterm=NONE

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
highlight! link PmenuSel                  Search
highlight! link WildMenu                  Search
highlight! link ALEWarningSign            GitGutterChange
highlight! link ALEErrorSign              GitGutterChange
highlight! link ALEInfoSign               GitGutterChangeLine
highlight! link CursorColumn              CursorLine
highlight! link ColorColumn               CursorLine
highlight! link SignColumn                LineNr
highlight! link FoldColumn                LineNr
highlight! link Folded                    LineNr
highlight! link TabLineFill               TabLine
highlight! link BufTabLineCurrent         Normal
highlight! link BufTabLineHidden          StatusLineNC
highlight! link BufTabLineFill            StatusLineNC
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
highlight! link TermCursorNC              String
