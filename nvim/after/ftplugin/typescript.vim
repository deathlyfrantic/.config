setlocal foldcolumn=0

setlocal cinoptions-=(0
setlocal cinoptions-=:0
setlocal cinoptions+=l1

iabbrev <buffer> != !==
iabbrev <buffer> == ===
iabbrev <buffer> fn function

setlocal omnifunc=ale#completion#OmniFunc
nnoremap <buffer> gd <Plug>(ale_go_to_definition)
nnoremap <buffer> <C-w>i <Plug>(ale_go_to_definition_in_split)
