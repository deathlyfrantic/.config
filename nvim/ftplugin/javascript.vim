setlocal cinoptions-=(0
setlocal cinoptions-=:0

iabbrev <buffer> != !==
iabbrev <buffer> == ===
iabbrev <buffer> fn function

" if line('$') == 1 && getline(1) == ""
"   call setline(1, '"use strict";')
"   call setline(2, "")
"   call cursor(2, 1)
" endif

let b:npm_bin = get(b:, 'npm_bin', z#sys_chomp('npm bin'))

" neomake {{{
let b:neomake_javascript_enabled_makers = []
let eslint = printf('%s/eslint', b:npm_bin)
if executable(eslint)
  let b:neomake_javascript_eslint_exe =
    \ get(b:, 'neomake_javascript_eslint_exe', eslint)
  let b:neomake_javascript_enabled_makers += ['eslint']
endif
unlet! eslint

let flow = printf('%s/flow', b:npm_bin)
if executable(flow)
  let b:neomake_javascript_flow_exe =
    \ get(b:, 'neomake_javascript_flow_exe', flow)
  let b:neomake_javascript_enabled_makers += ['flow']
endif
unlet! flow
" }}}

let b:neoformat_enabled_javascript = get(b:, 'neoformat_enabled_javascript',
  \ filter(neoformat#formatters#javascript#enabled(),
  \ {i, v -> v != 'clangformat'}))
