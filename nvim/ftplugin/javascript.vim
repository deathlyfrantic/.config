iabbrev <buffer> != !==
iabbrev <buffer> == ===
iabbrev <buffer> fn function

if line('$') == 1 && getline(1) == ""
  call setline(1, '"use strict";')
  call setline(2, "")
  call cursor(2, 1)
endif
