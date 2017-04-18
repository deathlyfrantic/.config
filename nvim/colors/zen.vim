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
    if &t_Co < 256
        echoerr 'The zen colorscheme requires a 256-color terminal or true-color Vim (Neovim or Gvim).'
        finish
    endif
endif

highlight clear

if exists('syntax_on')
    syntax reset
endif

let g:colors_name = 'zen'

let s:palette = [
    \ '#000000', '#800000', '#008000', '#808000', '#000080', '#800080', '#008080', '#c0c0c0',
    \ '#808080', '#ff0000', '#00ff00', '#ffff00', '#0000ff', '#ff00ff', '#00ffff', '#ffffff',
    \ '#000000', '#00005f', '#000087', '#0000af', '#0000d7', '#0000ff', '#005f00', '#005f5f',
    \ '#005f87', '#005faf', '#005fd7', '#005fff', '#008700', '#00875f', '#008787', '#0087af',
    \ '#0087d7', '#0087ff', '#00af00', '#00af5f', '#00af87', '#00afaf', '#00afd7', '#00afff',
    \ '#00d700', '#00d75f', '#00d787', '#00d7af', '#00d7d7', '#00d7ff', '#00ff00', '#00ff5f',
    \ '#00ff87', '#00ffaf', '#00ffd7', '#00ffff', '#5f0000', '#5f005f', '#5f0087', '#5f00af',
    \ '#5f00d7', '#5f00ff', '#5f5f00', '#5f5f5f', '#5f5f87', '#5f5faf', '#5f5fd7', '#5f5fff',
    \ '#5f8700', '#5f875f', '#5f8787', '#5f87af', '#5f87d7', '#5f87ff', '#5faf00', '#5faf5f',
    \ '#5faf87', '#5fafaf', '#5fafd7', '#5fafff', '#5fd700', '#5fd75f', '#5fd787', '#5fd7af',
    \ '#5fd7d7', '#5fd7ff', '#5fff00', '#5fff5f', '#5fff87', '#5fffaf', '#5fffd7', '#5fffff',
    \ '#870000', '#87005f', '#870087', '#8700af', '#8700d7', '#8700ff', '#875f00', '#875f5f',
    \ '#875f87', '#875faf', '#875fd7', '#875fff', '#878700', '#87875f', '#878787', '#8787af',
    \ '#8787d7', '#8787ff', '#87af00', '#87af5f', '#87af87', '#87afaf', '#87afd7', '#87afff',
    \ '#87d700', '#87d75f', '#87d787', '#87d7af', '#87d7d7', '#87d7ff', '#87ff00', '#87ff5f',
    \ '#87ff87', '#87ffaf', '#87ffd7', '#87ffff', '#af0000', '#af005f', '#af0087', '#af00af',
    \ '#af00d7', '#af00ff', '#af5f00', '#af5f5f', '#af5f87', '#af5faf', '#af5fd7', '#af5fff',
    \ '#af8700', '#af875f', '#af8787', '#af87af', '#af87d7', '#af87ff', '#afaf00', '#afaf5f',
    \ '#afaf87', '#afafaf', '#afafd7', '#afafff', '#afd700', '#afd75f', '#afd787', '#afd7af',
    \ '#afd7d7', '#afd7ff', '#afff00', '#afff5f', '#afff87', '#afffaf', '#afffd7', '#afffff',
    \ '#d70000', '#d7005f', '#d70087', '#d700af', '#d700d7', '#d700ff', '#d75f00', '#d75f5f',
    \ '#d75f87', '#d75faf', '#d75fd7', '#d75fff', '#d78700', '#d7875f', '#d78787', '#d787af',
    \ '#d787d7', '#d787ff', '#d7af00', '#d7af5f', '#d7af87', '#d7afaf', '#d7afd7', '#d7afff',
    \ '#d7d700', '#d7d75f', '#d7d787', '#d7d7af', '#d7d7d7', '#d7d7ff', '#d7ff00', '#d7ff5f',
    \ '#d7ff87', '#d7ffaf', '#d7ffd7', '#d7ffff', '#ff0000', '#ff005f', '#ff0087', '#ff00af',
    \ '#ff00d7', '#ff00ff', '#ff5f00', '#ff5f5f', '#ff5f87', '#ff5faf', '#ff5fd7', '#ff5fff',
    \ '#ff8700', '#ff875f', '#ff8787', '#ff87af', '#ff87d7', '#ff87ff', '#ffaf00', '#ffaf5f',
    \ '#ffaf87', '#ffafaf', '#ffafd7', '#ffafff', '#ffd700', '#ffd75f', '#ffd787', '#ffd7af',
    \ '#ffd7d7', '#ffd7ff', '#ffff00', '#ffff5f', '#ffff87', '#ffffaf', '#ffffd7', '#ffffff',
    \ '#080808', '#121212', '#1c1c1c', '#262626', '#303030', '#3a3a3a', '#444444', '#4e4e4e',
    \ '#585858', '#606060', '#666666', '#767676', '#808080', '#8a8a8a', '#949494', '#9e9e9e',
    \ '#a8a8a8', '#b2b2b2', '#bcbcbc', '#c6c6c6', '#d0d0d0', '#dadada', '#e4e4e4', '#eeeeee',
    \ ]

function! s:hi(group, fg, bg, mod)
    let l:guifg = (a:fg == 'NONE') ? 'NONE' : s:palette[a:fg]
    let l:guibg = (a:bg == 'NONE') ? 'NONE' : s:palette[a:bg]
    execute 'highlight '.a:group
        \ .' ctermfg='.a:fg
        \ .' ctermbg='.a:bg
        \ .' cterm='  .a:mod
        \ .' guifg='  .l:guifg
        \ .' guibg='  .l:guibg
        \ .' gui='    .a:mod
endfunction

call s:hi('Normal'               , 249   , 237   , 'NONE')
call s:hi('Visual'               , 'NONE', 235   , 'NONE')
call s:hi('CursorLine'           , 'NONE', 238   , 'NONE')
call s:hi('CursorLineNr'         , 246   , 238   , 'NONE')
call s:hi('LineNr'               , 235   , 'NONE', 'NONE')
call s:hi('StatusLine'           , 246   , 235   , 'NONE')
call s:hi('StatusLineNC'         , 242   , 234   , 'NONE')
call s:hi('VertSplit'            , 235   , 'NONE', 'NONE')
call s:hi('Comment'              , 59    , 'NONE', 'NONE')
call s:hi('String'               , 246   , 'NONE', 'NONE')
call s:hi('GitGutterChange'      , 226   , 'NONE', 'NONE')
call s:hi('GitGutterAdd'         , 46    , 'NONE', 'NONE')
call s:hi('MatchParen'           , 202   , 'NONE', 'bold')
call s:hi('WildMenu'             , 231   , 25    , 'NONE')
call s:hi('Pmenu'                , 234   , 245   , 'NONE')
call s:hi('PmenuSbar'            , 244   , 240   , 'NONE')
call s:hi('PmenuThumb'           , 'NONE', 249   , 'NONE')
call s:hi('Error'                , 196   , 'NONE', 'NONE')
call s:hi('SpellBad'             , 196   , 'NONE', 'underline')
call s:hi('SpellCap'             , 202   , 'NONE', 'underline')
call s:hi('Search'               , 231   , 25    , 'NONE')
call s:hi('TODO'                 , 202   , 'NONE', 'bold,underline')
call s:hi('DiffAdd'              , 46    , 28    , 'NONE')
call s:hi('DiffChange'           , 226   , 'NONE', 'NONE')
call s:hi('DiffText'             , 226   , 100   , 'NONE')
call s:hi('DiffDelete'           , 196   , 88    , 'NONE')
call s:hi('GitGutterChangeDelete', 202   , 'NONE', 'NONE')
call s:hi('ErrorMsg'             , 231   , 196   , 'bold')
call s:hi('WarningMsg'           , 231   , 166   , 'bold')
call s:hi('TabLine'              , 244   , 235   , 'NONE')
call s:hi('TabLineSel'           , 'NONE', 'NONE', 'NONE')
call s:hi('TabLineClose'         , 'NONE', 'NONE', 'NONE')
call s:hi('Directory'            , 'NONE', 'NONE', 'NONE')
call s:hi('Underlined'           , 'NONE', 'NONE', 'NONE')
call s:hi('Question'             , 'NONE', 'NONE', 'NONE')
call s:hi('MoreMsg'              , 'NONE', 'NONE', 'NONE')
call s:hi('ModeMsg'              , 'NONE', 'NONE', 'NONE')
call s:hi('SpellRare'            , 'NONE', 'NONE', 'NONE')
call s:hi('SpellLocal'           , 'NONE', 'NONE', 'NONE')
call s:hi('Boolean'              , 'NONE', 'NONE', 'NONE')
call s:hi('Constant'             , 'NONE', 'NONE', 'NONE')
call s:hi('Special'              , 'NONE', 'NONE', 'NONE')
call s:hi('Identifier'           , 'NONE', 'NONE', 'NONE')
call s:hi('Statement'            , 'NONE', 'NONE', 'NONE')
call s:hi('PreProc'              , 'NONE', 'NONE', 'NONE')
call s:hi('Type'                 , 'NONE', 'NONE', 'NONE')
call s:hi('Define'               , 'NONE', 'NONE', 'NONE')
call s:hi('Number'               , 'NONE', 'NONE', 'NONE')
call s:hi('Function'             , 'NONE', 'NONE', 'NONE')
call s:hi('Include'              , 'NONE', 'NONE', 'NONE')
call s:hi('PreCondit'            , 'NONE', 'NONE', 'NONE')
call s:hi('Keyword'              , 'NONE', 'NONE', 'NONE')
call s:hi('Title'                , 'NONE', 'NONE', 'NONE')
call s:hi('Delimiter'            , 'NONE', 'NONE', 'NONE')
call s:hi('StorageClass'         , 'NONE', 'NONE', 'NONE')
call s:hi('Operator'             , 'NONE', 'NONE', 'NONE')

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

unlet s:palette
