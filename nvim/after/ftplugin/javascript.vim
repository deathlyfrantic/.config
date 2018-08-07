setlocal cinoptions-=(0
setlocal cinoptions-=:0
setlocal cinoptions+=l1

iabbrev <buffer> != !==
iabbrev <buffer> == ===
iabbrev <buffer> fn function

" if line('$') == 1 && getline(1) == ""
"   call setline(1, '"use strict";')
"   call setline(2, "")
"   call cursor(2, 1)
" endif

" don't use clangformat for js
let b:neoformat_enabled_javascript = get(b:, 'neoformat_enabled_javascript',
  \ filter(neoformat#formatters#javascript#enabled(),
  \ {i, v -> v != 'clangformat'}))
