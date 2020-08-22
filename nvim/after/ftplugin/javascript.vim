setlocal cinoptions-=(0
setlocal cinoptions-=:0
setlocal cinoptions+=l1

" don't use clangformat for js
packadd neoformat
let b:neoformat_enabled_javascript = get(b:, 'neoformat_enabled_javascript',
      \ filter(neoformat#formatters#javascript#enabled(),
      \ {i, v -> v != 'clangformat'}))
