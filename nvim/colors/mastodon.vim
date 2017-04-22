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
if !has('gui_running') && !((&termguicolors) || (has('nvim') && $NVIM_TUI_ENABLE_TRUE_COLOR))
    echoerr 'The mastodon colorscheme requires a true-color Vim (Neovim or Gvim).'
    finish
endif

highlight clear

if exists('syntax_on')
    syntax reset
endif

let g:colors_name = 'mastodon'

" colors
" 191b22
" 282c37
" 393f4f
" 3b434e
" 444b5d
" 4c5269
" 5b606a
" 606984
" 707b97
" b2becd
" 92a1b4
" 9baec8
" ffffff
" ca8f04
" 2588d0
" ebebeb
" c4c8d2

highlight Normal                guifg=#c4c8d2 guibg=#282c37 gui=NONE
highlight Visual                guifg=NONE    guibg=#191b22 gui=NONE
highlight CursorLine            guifg=NONE    guibg=#30343f gui=NONE
highlight CursorLineNr          guifg=#9baec8 guibg=#30343f gui=NONE
highlight LineNr                guifg=#4c5269 guibg=NONE    gui=NONE
highlight StatusLine            guifg=#c4c8d2 guibg=#444b5d gui=NONE
highlight StatusLineNC          guifg=#444b5d guibg=#191b22 gui=NONE
highlight VertSplit             guifg=#191b22 guibg=NONE    gui=NONE
highlight Comment               guifg=#606984 guibg=NONE    gui=NONE
highlight String                guifg=#9ca7c9 guibg=NONE    gui=NONE
highlight MatchParen            guifg=#ff7722 guibg=NONE    gui=bold
highlight Pmenu                 guifg=#c4c8d2 guibg=#444b5d gui=NONE
highlight PmenuSbar             guifg=#707b97 guibg=#707b97 gui=NONE
highlight PmenuThumb            guifg=NONE    guibg=#3b434e gui=NONE
highlight Error                 guifg=#f50039 guibg=NONE    gui=NONE
highlight SpellBad              guifg=#f50039 guibg=NONE    gui=underline
highlight SpellCap              guifg=#ff7722 guibg=NONE    gui=underline
highlight Search                guifg=#ffffff guibg=#1f72ad gui=NONE
highlight TODO                  guifg=#ff7722 guibg=NONE    gui=bold,underline
highlight DiffAdd               guifg=#00f57a guibg=#006633 gui=NONE
highlight DiffChange            guifg=#e2e212 guibg=NONE    gui=NONE
highlight DiffText              guifg=#e2e212 guibg=#636303 gui=NONE
highlight DiffDelete            guifg=#f50039 guibg=#80001e gui=NONE
highlight GitGutterChange       guifg=#ff7722 guibg=NONE    gui=NONE
highlight GitGutterAdd          guifg=#00f57a guibg=NONE    gui=NONE
highlight GitGutterChangeDelete guifg=#ff7722 guibg=NONE    gui=NONE
highlight ErrorMsg              guifg=#ffffff guibg=#f50039 gui=bold
highlight WarningMsg            guifg=#ffffff guibg=#ff7722 gui=bold

highlight TabLineSel            guifg=NONE    guibg=NONE    gui=NONE
highlight TabLineClose          guifg=NONE    guibg=NONE    gui=NONE
highlight Directory             guifg=NONE    guibg=NONE    gui=NONE
highlight Underlined            guifg=NONE    guibg=NONE    gui=NONE
highlight Question              guifg=NONE    guibg=NONE    gui=NONE
highlight MoreMsg               guifg=NONE    guibg=NONE    gui=NONE
highlight ModeMsg               guifg=NONE    guibg=NONE    gui=NONE
highlight SpellRare             guifg=NONE    guibg=NONE    gui=NONE
highlight SpellLocal            guifg=NONE    guibg=NONE    gui=NONE
highlight Boolean               guifg=NONE    guibg=NONE    gui=NONE
highlight Constant              guifg=NONE    guibg=NONE    gui=NONE
highlight Special               guifg=NONE    guibg=NONE    gui=NONE
highlight Identifier            guifg=NONE    guibg=NONE    gui=NONE
highlight Statement             guifg=NONE    guibg=NONE    gui=NONE
highlight PreProc               guifg=NONE    guibg=NONE    gui=NONE
highlight Type                  guifg=NONE    guibg=NONE    gui=NONE
highlight Define                guifg=NONE    guibg=NONE    gui=NONE
highlight Number                guifg=NONE    guibg=NONE    gui=NONE
highlight Function              guifg=NONE    guibg=NONE    gui=NONE
highlight Include               guifg=NONE    guibg=NONE    gui=NONE
highlight PreCondit             guifg=NONE    guibg=NONE    gui=NONE
highlight Keyword               guifg=NONE    guibg=NONE    gui=NONE
highlight Title                 guifg=NONE    guibg=NONE    gui=NONE
highlight Delimiter             guifg=NONE    guibg=NONE    gui=NONE
highlight StorageClass          guifg=NONE    guibg=NONE    gui=NONE
highlight Operator              guifg=NONE    guibg=NONE    gui=NONE

highlight! link TabLine            StatusLine
highlight! link WildMenu           Search
highlight! link NeomakeWarningSign MatchParen
highlight! link NeomakeErrorSign   Error
highlight! link GitGutterDelete    Error
highlight! link CursorColumn       CursorLine
highlight! link ColorColumn        CursorLine
highlight! link PmenuSel           WildMenu
highlight! link SignColumn         LineNr
highlight! link FoldColumn         LineNr
highlight! link Folded             LineNr
highlight! link TabLineFill        TabLine
highlight! link BufTabLineActive   StatusLine
highlight! link BufTabLineCurrent  TabLineSel
highlight! link BufTabLineHidden   TabLine
highlight! link BufTabLineFill     TabLine
highlight! link CtrlPMode1         StatusLine
highlight! link CtrlPMode2         StatusLine
highlight! link SpecialKey         LineNr
highlight! link NonText            LineNr
highlight! link Conceal            Comment
highlight! link phpDocTags         Comment
highlight! link IncSearch          Search
highlight! link gitcommitOverflow  Error
highlight! link SneakPluginTarget  Search
highlight! link diffAdded          DiffAdd
highlight! link diffRemoved        DiffDelete
highlight! link mailQuoted1        String
highlight! link mailQuoted2        Comment
highlight! link pythonDocString    Comment
