if !has('gui_running') && !&termguicolors
  if &t_Co < 256
    echoerr 'The nihil colorscheme requires a 256-color terminal or true-color Vim (Neovim or Gvim).'
    finish
  endif
endif

highlight clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'nihil'

if &background == 'dark'
  highlight Normal          ctermfg=249  ctermbg=16   cterm=NONE guifg=#b2b2b2 guibg=#000000 gui=NONE
  highlight Visual          ctermfg=16   ctermbg=249  cterm=NONE guifg=#000000 guibg=#b2b2b2 gui=NONE
  highlight Cursorline      ctermfg=NONE ctermbg=233  cterm=NONE guifg=NONE    guibg=#121212 gui=NONE
  highlight CursorLineNr    ctermfg=249  ctermbg=233  cterm=NONE guifg=#b2b2b2 guibg=#121212 gui=NONE
  highlight StatusLine      ctermfg=16   ctermbg=245  cterm=NONE guifg=#000000 guibg=#8a8a8a gui=NONE
  highlight StatusLineNC    ctermfg=16   ctermbg=238  cterm=NONE guifg=#000000 guibg=#444444 gui=NONE
  highlight LineNr          ctermfg=238  ctermbg=NONE cterm=NONE guifg=#444444 guibg=NONE    gui=NONE
  highlight VertSplit       ctermfg=238  ctermbg=NONE cterm=NONE guifg=#444444 guibg=NONE    gui=NONE
  highlight Comment         ctermfg=238  ctermbg=NONE cterm=NONE guifg=#444444 guibg=NONE    gui=NONE
  highlight String          ctermfg=244  ctermbg=NONE cterm=NONE guifg=#808080 guibg=NONE    gui=NONE
  highlight GitGutterChange ctermfg=184  ctermbg=NONE cterm=NONE guifg=#d7d700 guibg=NONE    gui=NONE
else
  highlight Normal          ctermfg=235  ctermbg=251  cterm=NONE guifg=#262626 guibg=#c6c6c6 gui=NONE
  highlight Visual          ctermfg=251  ctermbg=235  cterm=NONE guifg=#c6c6c6 guibg=#262626 gui=NONE
  highlight Cursorline      ctermfg=NONE ctermbg=252  cterm=NONE guifg=NONE    guibg=#d0d0d0 gui=NONE
  highlight CursorLineNr    ctermfg=235  ctermbg=252  cterm=NONE guifg=#262626 guibg=#d0d0d0 gui=NONE
  highlight StatusLine      ctermfg=251  ctermbg=235  cterm=NONE guifg=#c6c6c6 guibg=#262626 gui=NONE
  highlight StatusLineNC    ctermfg=251  ctermbg=238  cterm=NONE guifg=#c6c6c6 guibg=#444444 gui=NONE
  highlight LineNr          ctermfg=246  ctermbg=NONE cterm=NONE guifg=#949494 guibg=NONE    gui=NONE
  highlight VertSplit       ctermfg=235  ctermbg=NONE cterm=NONE guifg=#262626 guibg=NONE    gui=NONE
  highlight Comment         ctermfg=246  ctermbg=NONE cterm=NONE guifg=#949494 guibg=NONE    gui=NONE
  highlight String          ctermfg=239  ctermbg=NONE cterm=NONE guifg=#4e4e4e guibg=NONE    gui=NONE
  highlight GitGutterChange ctermfg=226  ctermbg=NONE cterm=NONE guifg=#ffff00 guibg=NONE    gui=NONE
endif

highlight GitGutterAdd          ctermfg=34   ctermbg=NONE cterm=NONE           guifg=#00af00 guibg=NONE    gui=NONE
highlight MatchParen            ctermfg=202  ctermbg=NONE cterm=bold           guifg=#ff5f00 guibg=NONE    gui=bold
highlight WildMenu              ctermfg=255  ctermbg=25   cterm=NONE           guifg=#eeeeee guibg=#005fff gui=NONE
highlight PmenuSbar             ctermfg=244  ctermbg=240  cterm=NONE           guifg=#808080 guibg=#585858 gui=NONE
highlight PmenuThumb            ctermfg=NONE ctermbg=249  cterm=NONE           guifg=NONE    guibg=#b2b2b2 gui=NONE
highlight Error                 ctermfg=196  ctermbg=NONE cterm=NONE           guifg=#ff0000 guibg=NONE    gui=NONE
highlight SpellBad              ctermfg=196  ctermbg=NONE cterm=underline      guifg=#ff0000 guibg=NONE    gui=underline
highlight SpellCap              ctermfg=202  ctermbg=NONE cterm=underline      guifg=#ff5f00 guibg=NONE    gui=underline
highlight Search                ctermfg=231  ctermbg=27   cterm=NONE           guifg=#ffffff guibg=#005fff gui=NONE
highlight TODO                  ctermfg=202  ctermbg=NONE cterm=bold,underline guifg=#ff5f00 guibg=NONE    gui=bold,underline
highlight DiffAdd               ctermfg=46   ctermbg=28   cterm=NONE           guifg=#00ff00 guibg=#008700 gui=NONE
highlight DiffChange            ctermfg=226  ctermbg=NONE cterm=NONE           guifg=#ffff00 guibg=NONE    gui=NONE
highlight DiffText              ctermfg=226  ctermbg=100  cterm=NONE           guifg=#ffff00 guibg=#878700 gui=NONE
highlight DiffDelete            ctermfg=196  ctermbg=88   cterm=NONE           guifg=#ff0000 guibg=#870000 gui=NONE
highlight GitGutterChangeDelete ctermfg=202  ctermbg=NONE cterm=NONE           guifg=#ff5f00 guibg=NONE    gui=NONE
highlight ErrorMsg              ctermfg=231  ctermbg=196  cterm=bold           guifg=#ffffff guibg=#ff0000 gui=bold
highlight WarningMsg            ctermfg=231  ctermbg=202  cterm=bold           guifg=#ffffff guibg=#ff5f00 gui=bold

source $VIMHOME/colors/mono-base.vim
