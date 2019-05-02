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

source $VIMHOME/colors/mono-base.vim
