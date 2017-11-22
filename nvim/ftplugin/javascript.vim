setlocal cinoptions-=(0
setlocal cinoptions-=:0

iabbrev <buffer> != !==
iabbrev <buffer> == ===
iabbrev <buffer> fn function

if line('$') == 1 && getline(1) == ""
  call setline(1, '"use strict";')
  call setline(2, "")
  call cursor(2, 1)
endif

let eslint = printf('%s/eslint', substitute(system('npm bin'), '\n', '', ''))

if executable(eslint)
  let b:neomake_javascript_eslint_exe = eslint
endif

unlet eslint
