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
if !has('gui_running') && !&termguicolors
  echoerr 'The copper colorscheme requires a true-color Vim (Neovim or Gvim).'
  finish
endif

highlight clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'copper'

highlight Normal                guifg=#d2c8c4 guibg=#000000 gui=NONE           cterm=NONE
highlight Visual                guifg=NONE    guibg=#221b19 gui=NONE           cterm=NONE
highlight CursorLine            guifg=NONE    guibg=#19100d gui=NONE           cterm=NONE
highlight CursorLineNr          guifg=#c8ae9b guibg=#19100d gui=NONE           cterm=NONE
highlight LineNr                guifg=#69524c guibg=NONE    gui=NONE           cterm=NONE
highlight StatusLine            guifg=#d2c8c4 guibg=#5d4b44 gui=NONE           cterm=NONE
highlight StatusLineNC          guifg=#5d4b44 guibg=#221b19 gui=NONE           cterm=NONE
highlight VertSplit             guifg=#221b19 guibg=NONE    gui=NONE           cterm=NONE
highlight Comment               guifg=#846960 guibg=NONE    gui=NONE           cterm=NONE
highlight String                guifg=#c9a79c guibg=NONE    gui=NONE           cterm=NONE
highlight MatchParen            guifg=#ff7700 guibg=NONE    gui=bold           cterm=NONE
highlight Pmenu                 guifg=#d2c8c4 guibg=#5d4b44 gui=NONE           cterm=NONE
highlight PmenuSbar             guifg=#977b70 guibg=#977b70 gui=NONE           cterm=NONE
highlight PmenuThumb            guifg=NONE    guibg=#4e433b gui=NONE           cterm=NONE
highlight Error                 guifg=#f53900 guibg=NONE    gui=NONE           cterm=NONE
highlight SpellBad              guifg=#f53900 guibg=NONE    gui=underline      cterm=underline
highlight SpellCap              guifg=#ff7700 guibg=NONE    gui=underline      cterm=underline
highlight Search                guifg=#ffffff guibg=#ad721f gui=NONE           cterm=NONE
highlight TODO                  guifg=#ff7700 guibg=NONE    gui=bold,underline cterm=bold,underline
highlight DiffAdd               guifg=#7af500 guibg=#336600 gui=NONE           cterm=NONE
highlight DiffChange            guifg=#e2e212 guibg=NONE    gui=NONE           cterm=NONE
highlight DiffText              guifg=#e2e212 guibg=#636303 gui=NONE           cterm=NONE
highlight DiffDelete            guifg=#f53900 guibg=#80001e gui=NONE           cterm=NONE
highlight GitGutterChange       guifg=#ff7700 guibg=NONE    gui=NONE           cterm=NONE
highlight GitGutterAdd          guifg=#7af500 guibg=NONE    gui=NONE           cterm=NONE
highlight GitGutterChangeDelete guifg=#ff7700 guibg=NONE    gui=NONE           cterm=NONE
highlight ErrorMsg              guifg=#ffffff guibg=#f53900 gui=bold           cterm=bold
highlight WarningMsg            guifg=#ffffff guibg=#ff7700 gui=bold           cterm=bold
highlight BufTabLineActive      guifg=#c9a79c guibg=#5d4b44 gui=NONE           cterm=NONE
highlight TermCursorNC          guifg=#000000 guibg=#846960 gui=NONE           cterm=NONE

source $VIMHOME/colors/mono-base.vim
