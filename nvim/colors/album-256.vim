if &t_Co < 256
  echoerr 'The album-256 colorscheme requires a 256-color Vim.'
  finish
endif

highlight clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'album-256'

highlight Normal                ctermfg=253  ctermbg=234  cterm=NONE
highlight Visual                ctermfg=NONE ctermbg=232  cterm=NONE
highlight CursorLine            ctermfg=NONE ctermbg=235  cterm=NONE
highlight CursorLineNr          ctermfg=240  ctermbg=235  cterm=NONE
highlight LineNr                ctermfg=238  ctermbg=NONE cterm=NONE
highlight StatusLine            ctermfg=253  ctermbg=65   cterm=NONE
highlight StatusLineNC          ctermfg=232  ctermbg=59   cterm=NONE
highlight VertSplit             ctermfg=232  ctermbg=NONE cterm=NONE
highlight Comment               ctermfg=240  ctermbg=NONE cterm=NONE
highlight String                ctermfg=247  ctermbg=NONE cterm=NONE
highlight MatchParen            ctermfg=215  ctermbg=236  cterm=bold
highlight Pmenu                 ctermfg=232  ctermbg=244  cterm=NONE
highlight PmenuSbar             ctermfg=246  ctermbg=246  cterm=NONE
highlight PmenuThumb            ctermfg=250  ctermbg=250  cterm=NONE
highlight Error                 ctermfg=197  ctermbg=NONE cterm=NONE
highlight SpellBad              ctermfg=197  ctermbg=NONE cterm=underline
highlight SpellCap              ctermfg=215  ctermbg=NONE cterm=underline
highlight Search                ctermfg=232  ctermbg=114  cterm=NONE
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
highlight BufTabLineActive      ctermfg=232  ctermbg=65   cterm=NONE
highlight Cursor                ctermfg=bg   ctermbg=fg   cterm=NONE
highlight TermCursor            ctermfg=bg   ctermbg=fg   cterm=NONE

source $VIMHOME/colors/mono-base.vim
