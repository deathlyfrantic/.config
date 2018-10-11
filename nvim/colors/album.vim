if !has('gui_running') && !&termguicolors
  echoerr 'The album colorscheme requires a true-color Vim (Neovim or Gvim).'
  finish
endif

highlight clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'album'

highlight Normal                guifg=#dadada guibg=#1c1c1c gui=NONE           cterm=NONE
highlight Visual                guifg=NONE    guibg=#080808 gui=NONE           cterm=NONE
highlight CursorLine            guifg=NONE    guibg=#262626 gui=NONE           cterm=NONE
highlight CursorLineNr          guifg=#585858 guibg=#262626 gui=NONE           cterm=NONE
highlight LineNr                guifg=#444444 guibg=NONE    gui=NONE           cterm=NONE
highlight StatusLine            guifg=#dadada guibg=#5f875f gui=NONE           cterm=NONE
highlight StatusLineNC          guifg=#080808 guibg=#3f5a3f gui=NONE           cterm=NONE
highlight VertSplit             guifg=#080808 guibg=NONE    gui=NONE           cterm=NONE
highlight Comment               guifg=#585858 guibg=NONE    gui=NONE           cterm=NONE
highlight String                guifg=#9e9e9e guibg=NONE    gui=NONE           cterm=NONE
highlight MatchParen            guifg=#ffaf5f guibg=#303030 gui=bold           cterm=bold
highlight Pmenu                 guifg=#080808 guibg=#808080 gui=NONE           cterm=NONE
highlight PmenuSbar             guifg=#949494 guibg=#949494 gui=NONE           cterm=NONE
highlight PmenuThumb            guifg=#bcbcbc guibg=#bcbcbc gui=NONE           cterm=NONE
highlight Error                 guifg=#ff005f guibg=NONE    gui=NONE           cterm=NONE
highlight SpellBad              guifg=#ff005f guibg=NONE    gui=underline      cterm=underline
highlight SpellCap              guifg=#ffaf5f guibg=NONE    gui=underline      cterm=underline
highlight Search                guifg=#080808 guibg=#87d787 gui=NONE           cterm=NONE
highlight TODO                  guifg=#ffff87 guibg=NONE    gui=bold,underline cterm=bold,underline
highlight DiffAdd               guifg=#87ff87 guibg=#00875f gui=NONE           cterm=NONE
highlight DiffChange            guifg=#ffff87 guibg=NONE    gui=NONE           cterm=NONE
highlight DiffText              guifg=#ffff87 guibg=#87875f gui=NONE           cterm=NONE
highlight DiffDelete            guifg=#ff005f guibg=#870000 gui=NONE           cterm=NONE
highlight GitGutterAdd          guifg=#87ff87 guibg=NONE    gui=NONE           cterm=NONE
highlight GitGutterChange       guifg=#ffaf5f guibg=NONE    gui=NONE           cterm=NONE
highlight GitGutterChangeDelete guifg=#ff875f guibg=NONE    gui=NONE           cterm=NONE
highlight GitGutterDelete       guifg=#ff005f guibg=NONE    gui=NONE           cterm=NONE
highlight ErrorMsg              guifg=#ffffff guibg=#ff005f gui=bold           cterm=bold
highlight WarningMsg            guifg=#ffffff guibg=#d7875f gui=bold           cterm=bold
highlight BufTabLineActive      guifg=#dadada guibg=#5f875f gui=NONE           cterm=NONE

source $VIMHOME/colors/mono-base.vim
