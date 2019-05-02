set termguicolors

highlight clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'mastodon'

highlight Normal                guifg=#c4c8d2 guibg=#282c37 gui=NONE           cterm=NONE
highlight Visual                guifg=NONE    guibg=#191b22 gui=NONE           cterm=NONE
highlight CursorLine            guifg=NONE    guibg=#30343f gui=NONE           cterm=NONE
highlight CursorLineNr          guifg=#9baec8 guibg=#30343f gui=NONE           cterm=NONE
highlight LineNr                guifg=#4c5269 guibg=NONE    gui=NONE           cterm=NONE
highlight StatusLine            guifg=#c4c8d2 guibg=#444b5d gui=NONE           cterm=NONE
highlight StatusLineNC          guifg=#444b5d guibg=#191b22 gui=NONE           cterm=NONE
highlight VertSplit             guifg=#191b22 guibg=NONE    gui=NONE           cterm=NONE
highlight Comment               guifg=#606984 guibg=NONE    gui=NONE           cterm=NONE
highlight String                guifg=#9ca7c9 guibg=NONE    gui=NONE           cterm=NONE
highlight MatchParen            guifg=#ff7722 guibg=NONE    gui=bold           cterm=NONE
highlight Pmenu                 guifg=#c4c8d2 guibg=#444b5d gui=NONE           cterm=NONE
highlight PmenuSbar             guifg=#707b97 guibg=#707b97 gui=NONE           cterm=NONE
highlight PmenuThumb            guifg=NONE    guibg=#3b434e gui=NONE           cterm=NONE
highlight Error                 guifg=#f50039 guibg=NONE    gui=NONE           cterm=NONE
highlight SpellBad              guifg=#f50039 guibg=NONE    gui=underline      cterm=underline
highlight SpellCap              guifg=#ff7722 guibg=NONE    gui=underline      cterm=underline
highlight Search                guifg=#ffffff guibg=#1f72ad gui=NONE           cterm=NONE
highlight TODO                  guifg=#ff7722 guibg=NONE    gui=bold,underline cterm=bold,underline
highlight DiffAdd               guifg=#00f57a guibg=#006633 gui=NONE           cterm=NONE
highlight DiffChange            guifg=#e2e212 guibg=NONE    gui=NONE           cterm=NONE
highlight DiffText              guifg=#e2e212 guibg=#636303 gui=NONE           cterm=NONE
highlight DiffDelete            guifg=#f50039 guibg=#80001e gui=NONE           cterm=NONE
highlight GitGutterChange       guifg=#ff7722 guibg=NONE    gui=NONE           cterm=NONE
highlight GitGutterAdd          guifg=#00f57a guibg=NONE    gui=NONE           cterm=NONE
highlight GitGutterChangeDelete guifg=#ff7722 guibg=NONE    gui=NONE           cterm=NONE
highlight ErrorMsg              guifg=#ffffff guibg=#f50039 gui=bold           cterm=bold
highlight WarningMsg            guifg=#ffffff guibg=#ff7722 gui=bold           cterm=bold
highlight BufTabLineActive      guifg=#9ca7c9 guibg=#444b5d gui=NONE           cterm=NONE
highlight TermCursorNC          guifg=#000000 guibg=#606984 gui=NONE           cterm=NONE

source $VIMHOME/colors/mono-base.vim
