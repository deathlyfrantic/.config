set termguicolors

highlight clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'snowblind'

highlight Normal                guifg=#000000 guibg=#ffffff gui=NONE           cterm=NONE
highlight Visual                guifg=NONE    guibg=#dddddd gui=NONE           cterm=NONE
highlight CursorLine            guifg=NONE    guibg=#eeeeee gui=NONE           cterm=NONE
highlight CursorLineNr          guifg=#666666 guibg=#eeeeee gui=NONE           cterm=NONE
highlight LineNr                guifg=#888888 guibg=NONE    gui=NONE           cterm=NONE
highlight StatusLine            guifg=#ffffff guibg=#000000 gui=NONE           cterm=NONE
highlight StatusLineNC          guifg=#444b5d guibg=#eeeeee gui=NONE           cterm=NONE
highlight VertSplit             guifg=#eeeeee guibg=NONE    gui=NONE           cterm=NONE
highlight Comment               guifg=#888888 guibg=NONE    gui=NONE           cterm=NONE
highlight String                guifg=#555555 guibg=NONE    gui=NONE           cterm=NONE
highlight MatchParen            guifg=#ff8800 guibg=NONE    gui=bold           cterm=NONE
highlight Pmenu                 guifg=#ffffff guibg=#000000 gui=NONE           cterm=NONE
highlight PmenuSbar             guifg=#777777 guibg=#777777 gui=NONE           cterm=NONE
highlight PmenuThumb            guifg=NONE    guibg=#333333 gui=NONE           cterm=NONE
highlight Error                 guifg=#ff0000 guibg=NONE    gui=NONE           cterm=NONE
highlight SpellBad              guifg=#f50039 guibg=NONE    gui=underline      cterm=underline
highlight SpellCap              guifg=#ff8800 guibg=NONE    gui=underline      cterm=underline
highlight Search                guifg=#ffffff guibg=#3399ff gui=NONE           cterm=NONE
highlight TODO                  guifg=#ff8820 guibg=NONE    gui=bold,underline cterm=bold,underline
highlight DiffAdd               guifg=#00ff00 guibg=#008800 gui=NONE           cterm=NONE
highlight DiffChange            guifg=#ffff00 guibg=NONE    gui=NONE           cterm=NONE
highlight DiffText              guifg=#ffff00 guibg=#888800 gui=NONE           cterm=NONE
highlight DiffDelete            guifg=#ff0000 guibg=#880000 gui=NONE           cterm=NONE
highlight GitGutterChange       guifg=#ff8800 guibg=NONE    gui=NONE           cterm=NONE
highlight GitGutterAdd          guifg=#00ff00 guibg=NONE    gui=NONE           cterm=NONE
highlight GitGutterChangeDelete guifg=#ff8800 guibg=NONE    gui=NONE           cterm=NONE
highlight ErrorMsg              guifg=#ffffff guibg=#ff0000 gui=bold           cterm=bold
highlight WarningMsg            guifg=#ffffff guibg=#ff8800 gui=bold           cterm=bold
highlight BufTabLineActive      guifg=#aaaaaa guibg=#000000 gui=NONE           cterm=NONE

source $VIMHOME/colors/mono-base.vim

" highlight BoldyMcBoldFace gui=bold
" match BoldyMcBoldFace /./
