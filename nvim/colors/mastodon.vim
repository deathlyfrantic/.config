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

highlight Normal                guifg=#c4c8d2 guibg=#282c37 gui=NONE           cterm=NONE           term=NONE
highlight Visual                guifg=NONE    guibg=#191b22 gui=NONE           cterm=NONE           term=NONE
highlight CursorLine            guifg=NONE    guibg=#30343f gui=NONE           cterm=NONE           term=NONE
highlight CursorLineNr          guifg=#9baec8 guibg=#30343f gui=NONE           cterm=NONE           term=NONE
highlight LineNr                guifg=#4c5269 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight StatusLine            guifg=#c4c8d2 guibg=#444b5d gui=NONE           cterm=NONE           term=NONE
highlight StatusLineNC          guifg=#444b5d guibg=#191b22 gui=NONE           cterm=NONE           term=NONE
highlight VertSplit             guifg=#191b22 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Comment               guifg=#606984 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight String                guifg=#9ca7c9 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight MatchParen            guifg=#ff7722 guibg=NONE    gui=bold           cterm=NONE           term=NONE
highlight Pmenu                 guifg=#c4c8d2 guibg=#444b5d gui=NONE           cterm=NONE           term=NONE
highlight PmenuSbar             guifg=#707b97 guibg=#707b97 gui=NONE           cterm=NONE           term=NONE
highlight PmenuThumb            guifg=NONE    guibg=#3b434e gui=NONE           cterm=NONE           term=NONE
highlight Error                 guifg=#f50039 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight SpellBad              guifg=#f50039 guibg=NONE    gui=underline      cterm=underline      term=underline
highlight SpellCap              guifg=#ff7722 guibg=NONE    gui=underline      cterm=underline      term=underline
highlight Search                guifg=#ffffff guibg=#1f72ad gui=NONE           cterm=NONE           term=NONE
highlight TODO                  guifg=#ff7722 guibg=NONE    gui=bold,underline cterm=bold,underline term=bold,underline
highlight DiffAdd               guifg=#00f57a guibg=#006633 gui=NONE           cterm=NONE           term=NONE
highlight DiffChange            guifg=#e2e212 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight DiffText              guifg=#e2e212 guibg=#636303 gui=NONE           cterm=NONE           term=NONE
highlight DiffDelete            guifg=#f50039 guibg=#80001e gui=NONE           cterm=NONE           term=NONE
highlight GitGutterChange       guifg=#ff7722 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight GitGutterAdd          guifg=#00f57a guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight GitGutterChangeDelete guifg=#ff7722 guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight ErrorMsg              guifg=#ffffff guibg=#f50039 gui=bold           cterm=bold           term=bold
highlight WarningMsg            guifg=#ffffff guibg=#ff7722 gui=bold           cterm=bold           term=bold
highlight Whitespace            guifg=#30343f guibg=NONE    gui=NONE           cterm=NONE           term=NONE

highlight TabLineSel            guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight TabLineClose          guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Directory             guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Underlined            guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Question              guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight MoreMsg               guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight ModeMsg               guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight SpellRare             guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight SpellLocal            guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Boolean               guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Constant              guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Special               guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Identifier            guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Statement             guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight PreProc               guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Type                  guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Define                guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Number                guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Function              guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Include               guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight PreCondit             guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Keyword               guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Title                 guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Delimiter             guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight StorageClass          guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE
highlight Operator              guifg=NONE    guibg=NONE    gui=NONE           cterm=NONE           term=NONE

highlight! link TabLine                 StatusLine
highlight! link WildMenu                Search
highlight! link NeomakeWarningSign      MatchParen
highlight! link NeomakeErrorSign        Error
highlight! link GitGutterDelete         Error
highlight! link CursorColumn            CursorLine
highlight! link ColorColumn             CursorLine
highlight! link PmenuSel                WildMenu
highlight! link SignColumn              LineNr
highlight! link FoldColumn              LineNr
highlight! link Folded                  LineNr
highlight! link TabLineFill             TabLine
highlight! link BufTabLineActive        StatusLine
highlight! link BufTabLineCurrent       TabLineSel
highlight! link BufTabLineHidden        TabLine
highlight! link BufTabLineFill          TabLine
highlight! link CtrlPMode1              StatusLine
highlight! link CtrlPMode2              StatusLine
highlight! link SpecialKey              LineNr
highlight! link NonText                 LineNr
highlight! link Conceal                 Comment
highlight! link phpDocTags              Comment
highlight! link IncSearch               Search
highlight! link gitcommitOverflow       Error
highlight! link SneakPluginTarget       Search
highlight! link diffAdded               DiffAdd
highlight! link diffRemoved             DiffDelete
highlight! link mailQuoted1             String
highlight! link mailQuoted2             Comment
highlight! link pythonDocString         Comment
highlight! link TagbarVisibilityPublic  GitGutterAdd
highlight! link TagbarVisibilityPrivate GitGutterDelete
highlight! link Sneak                   Search
