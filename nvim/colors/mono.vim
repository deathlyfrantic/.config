" Copyright © 2017 Zandr Martin
" All rights reserved.

" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
" 1. Redistributions of source code must retain the above copyright
" notice, this list of conditions and the following disclaimer.
" 2. Redistributions in binary form must reproduce the above copyright
" notice, this list of conditions and the following disclaimer in the
" documentation and/or other materials provided with the distribution.

" THIS SOFTWARE IS PROVIDED BY Zandr Martin ''AS IS'' AND ANY
" EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
" WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
" DISCLAIMED. IN NO EVENT SHALL Zandr Martin BE LIABLE FOR ANY
" DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
" (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
" LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
" ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
" (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
" SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

" The views and conclusions contained in the software and documentation
" are those of the authors and should not be interpreted as representing
" official policies, either expressed or implied, of Zandr Martin.
if !has('gui_running') && !((&termguicolors) || (has('nvim') && $NVIM_TUI_ENABLE_TRUE_COLOR))
  echoerr 'The mono colorscheme requires a true-color Vim (Neovim or Gvim).'
  finish
endif

highlight clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'mono'

let s:palettes = {
  \ 'mastodon': {
  \   'fg':           'c4c8d2',
  \   'bg':           '282c37',
  \   'visual':       '191b22',
  \   'cursorline':   '30343f',
  \   'cursorlinenr': '9baec8',
  \   'linenr':       '4c5269',
  \   'statusline':   '444b5d',
  \   'comment':      '606984',
  \   'string':       '9ca7c9',
  \   'orange':       'ff7722',
  \   'pmenusbar':    '707b97',
  \   'pmenuthumb':   '3b434e',
  \   'red':          'f50039',
  \   'msgfg':        'ffffff',
  \   'search':       '1f72ad',
  \   'addfg':        '00f57a',
  \   'addbg':        '006633',
  \   'difffg':       'e2e212',
  \   'diffbg':       '636303',
  \   'deletebg':     '80001e',
  \   'whitespace':   '30343f'
  \ },
  \ 'mammoth': {
  \   'fg':           'd2c8c4',
  \   'bg':           '372c28',
  \   'visual':       '221b19',
  \   'cursorline':   '3f3430',
  \   'cursorlinenr': 'c8ae9b',
  \   'linenr':       '69524c',
  \   'statusline':   '5d4b44',
  \   'comment':      '846960',
  \   'string':       'c9a79c',
  \   'orange':       'ff7700',
  \   'pmenusbar':    '977b70',
  \   'pmenuthumb':   '4e433b',
  \   'red':          'f53900',
  \   'msgfg':        'ffffff',
  \   'search':       'ad721f',
  \   'addfg':        '7af500',
  \   'addbg':        '336600',
  \   'difffg':       'e2e212',
  \   'diffbg':       '636303',
  \   'deletebg':     '80001e',
  \   'whitespace':   '3f3430'
  \ },
  \ 'copper': {
  \   'fg':           'd2c8c4',
  \   'bg':           '000000',
  \   'visual':       '221b19',
  \   'cursorline':   '19100d',
  \   'cursorlinenr': 'c8ae9b',
  \   'linenr':       '69524c',
  \   'statusline':   '5d4b44',
  \   'comment':      '846960',
  \   'string':       'c9a79c',
  \   'orange':       'ff7700',
  \   'pmenusbar':    '977b70',
  \   'pmenuthumb':   '4e433b',
  \   'red':          'f53900',
  \   'msgfg':        'ffffff',
  \   'search':       'ad721f',
  \   'addfg':        '7af500',
  \   'addbg':        '336600',
  \   'difffg':       'e2e212',
  \   'diffbg':       '636303',
  \   'deletebg':     '80001e',
  \   'whitespace':   '3f3430'
  \ },
  \ }

let s:pal = s:palettes[get(g:, 'mono_palette', 'mastodon')]

exec 'highlight Normal guifg=#'.s:pal['fg'].' guibg=#'.s:pal['bg'].' gui=NONE'
exec 'highlight Visual guifg=NONE guibg=#'.s:pal['visual'].' gui=NONE'
exec 'highlight CursorLine guifg=NONE guibg=#'.s:pal['cursorline'].' gui=NONE'
exec 'highlight CursorLineNr guifg=#'.s:pal['cursorlinenr'].' guibg=#'.s:pal['cursorline'].' gui=NONE'
exec 'highlight LineNr guifg=#'.s:pal['linenr'].' guibg=NONE gui=NONE'
exec 'highlight StatusLine guifg=#'.s:pal['fg'].' guibg=#'.s:pal['statusline'].' gui=NONE'
exec 'highlight StatusLineNC guifg=#'.s:pal['statusline'].' guibg=#'.s:pal['visual'].' gui=NONE'
exec 'highlight VertSplit guifg=#'.s:pal['visual'].' guibg=NONE gui=NONE'
exec 'highlight Comment guifg=#'.s:pal['comment'].' guibg=NONE gui=NONE'
exec 'highlight String guifg=#'.s:pal['string'].' guibg=NONE gui=NONE'
exec 'highlight MatchParen guifg=#'.s:pal['orange'].' guibg=NONE gui=bold'
exec 'highlight Pmenu guifg=#'.s:pal['fg'].' guibg=#'.s:pal['statusline'].' gui=NONE'
exec 'highlight PmenuSbar guifg=#'.s:pal['pmenusbar'].' guibg=#'.s:pal['pmenusbar'].' gui=NONE'
exec 'highlight PmenuThumb guifg=NONE guibg=#'.s:pal['pmenuthumb'].' gui=NONE'
exec 'highlight Error guifg=#'.s:pal['red'].' guibg=NONE gui=NONE'
exec 'highlight SpellBad guifg=#'.s:pal['red'].' guibg=NONE gui=underline'
exec 'highlight SpellCap guifg=#'.s:pal['orange'].' guibg=NONE gui=underline'
exec 'highlight Search guifg=#'.s:pal['msgfg'].' guibg=#'.s:pal['search'].' gui=NONE'
exec 'highlight TODO guifg=#'.s:pal['orange'].' guibg=NONE gui=bold,underline'
exec 'highlight DiffAdd guifg=#'.s:pal['addfg'].' guibg=#'.s:pal['addbg'].' gui=NONE'
exec 'highlight DiffChange guifg=#'.s:pal['difffg'].' guibg=NONE gui=NONE'
exec 'highlight DiffText guifg=#'.s:pal['difffg'].' guibg=#'.s:pal['diffbg'].' gui=NONE'
exec 'highlight DiffDelete guifg=#'.s:pal['red'].' guibg=#'.s:pal['deletebg'].' gui=NONE'
exec 'highlight GitGutterChange guifg=#'.s:pal['orange'].' guibg=NONE gui=NONE'
exec 'highlight GitGutterAdd guifg=#'.s:pal['addfg'].' guibg=NONE gui=NONE'
exec 'highlight GitGutterChangeDelete guifg=#'.s:pal['orange'].' guibg=NONE gui=NONE'
exec 'highlight ErrorMsg guifg=#'.s:pal['msgfg'].' guibg=#'.s:pal['red'].' gui=bold'
exec 'highlight WarningMsg guifg=#'.s:pal['msgfg'].' guibg=#'.s:pal['orange'].' gui=bold'
exec 'highlight Whitespace guifg=#'.s:pal['whitespace'].' guibg=NONE gui=NONE'
exec 'highlight BufTabLineActive guifg=#'.s:pal['string'].' guibg=#'.s:pal['statusline'].' gui=NONE'

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

highlight! link TabLine                   StatusLine
highlight! link WildMenu                  Search
highlight! link NeomakeWarningSign        GitGutterChange
highlight! link NeomakeErrorSign          Error
highlight! link GitGutterDelete           Error
highlight! link CursorColumn              CursorLine
highlight! link ColorColumn               CursorLine
highlight! link PmenuSel                  WildMenu
highlight! link SignColumn                LineNr
highlight! link FoldColumn                LineNr
highlight! link Folded                    LineNr
highlight! link TabLineFill               TabLine
highlight! link BufTabLineCurrent         Normal
highlight! link BufTabLineHidden          TabLine
highlight! link BufTabLineFill            TabLine
highlight! link CtrlPMode1                StatusLine
highlight! link CtrlPMode2                StatusLine
highlight! link CtrlPMatch                String
highlight! link SpecialKey                LineNr
highlight! link NonText                   LineNr
highlight! link Conceal                   Comment
highlight! link phpDocTags                Comment
highlight! link IncSearch                 Search
highlight! link gitcommitOverflow         Error
highlight! link Sneak                     Search
highlight! link diffAdded                 DiffAdd
highlight! link diffRemoved               DiffDelete
highlight! link mailQuoted1               String
highlight! link mailQuoted2               Comment
highlight! link pythonDocString           Comment
highlight! link TagbarVisibilityProtected GitGutterChange
highlight! link TagbarVisibilityPublic    GitGutterAdd
highlight! link TagbarVisibilityPrivate   GitGutterDelete
