setlocal cinoptions-=(0

iabbrev <buffer> != !==
iabbrev <buffer> == ===
iabbrev <buffer> fn function

if line('$') == 1 && getline(1) == ""
  call setline(1, '"use strict";')
  call setline(2, "")
  call cursor(2, 1)
endif

let s:node_bin_dir = substitute(system('npm bin'), '\n', '', '')
let s:local_eslint_path = s:node_bin_dir . '/eslint'

if executable(s:local_eslint_path)
  let b:neomake_javascript_eslint_exe = s:local_eslint_path
endif
