setlocal cinoptions-=(0
setlocal cinoptions-=:0
setlocal cinoptions+=l1

setlocal omnifunc=ale#completion#OmniFunc
nmap <buffer> gd <Plug>(ale_go_to_definition)
nmap <buffer> <C-w>i <Plug>(ale_go_to_definition_in_split)
