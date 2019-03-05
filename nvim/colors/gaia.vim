if !has('gui_running') && !&termguicolors
  echoerr 'The gaia colorscheme requires a true-color Vim (Neovim or Gvim).'
  finish
endif

highlight clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'gaia'

highlight Normal                guifg=#dadada guibg=#1c1c1c gui=NONE           cterm=NONE
highlight Visual                guifg=#dadada guibg=#4e473a gui=NONE           cterm=NONE
highlight CursorLine            guifg=NONE    guibg=#262626 gui=NONE           cterm=NONE
highlight CursorLineNr          guifg=#585858 guibg=#262626 gui=NONE           cterm=NONE
highlight LineNr                guifg=#444444 guibg=NONE    gui=NONE           cterm=NONE
highlight StatusLine            guifg=#080808 guibg=#877a5c gui=NONE           cterm=NONE
highlight StatusLineNC          guifg=#080808 guibg=#4e473a gui=NONE           cterm=NONE
highlight VertSplit             guifg=#4e473a guibg=NONE    gui=NONE           cterm=NONE
highlight Comment               guifg=#585858 guibg=NONE    gui=NONE           cterm=NONE
highlight String                guifg=#9e9e9e guibg=NONE    gui=NONE           cterm=NONE
highlight MatchParen            guifg=#e09a5c guibg=#404040 gui=bold           cterm=bold
highlight Pmenu                 guifg=#080808 guibg=#606060 gui=NONE           cterm=NONE
highlight PmenuSbar             guifg=#949494 guibg=#808080 gui=NONE           cterm=NONE
highlight PmenuThumb            guifg=#bcbcbc guibg=#aaaaaa gui=NONE           cterm=NONE
highlight Error                 guifg=#ee6161 guibg=NONE    gui=NONE           cterm=NONE
highlight SpellBad              guifg=#ee6161 guibg=NONE    gui=underline      cterm=underline
highlight SpellCap              guifg=#dd8840 guibg=NONE    gui=underline      cterm=underline
highlight Search                guifg=#080808 guibg=#bbac88 gui=NONE           cterm=NONE
highlight TODO                  guifg=#eeee8f guibg=NONE    gui=bold,underline cterm=bold,underline
highlight DiffAdd               guifg=#76ee76 guibg=#367136 gui=NONE           cterm=NONE
highlight DiffChange            guifg=#dbdb6d guibg=NONE    gui=NONE           cterm=NONE
highlight DiffText              guifg=#eeee76 guibg=#717136 gui=NONE           cterm=NONE
highlight DiffDelete            guifg=#ee6161 guibg=#713636 gui=NONE           cterm=NONE
highlight GitGutterAdd          guifg=#76ee76 guibg=NONE    gui=NONE           cterm=NONE
highlight GitGutterChange       guifg=#dd8840 guibg=NONE    gui=NONE           cterm=NONE
highlight GitGutterChangeDelete guifg=#a46530 guibg=NONE    gui=NONE           cterm=NONE
highlight GitGutterDelete       guifg=#ee6161 guibg=NONE    gui=NONE           cterm=NONE
highlight ErrorMsg              guifg=#ffffff guibg=#a44e30 gui=bold           cterm=bold
highlight WarningMsg            guifg=#ffffff guibg=#a46530 gui=bold           cterm=bold
highlight BufTabLineActive      guifg=#dadada guibg=#877a5c gui=NONE           cterm=NONE

source $VIMHOME/colors/mono-base.vim
