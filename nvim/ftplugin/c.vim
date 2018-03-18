let s:headers = [
  \ 'signal',
  \ 'stdbool',
  \ 'stdint',
  \ 'stdio',
  \ 'stdlib',
  \ 'string',
  \ 'time',
  \ 'unistd',
  \ ]

let s:nested_headers = {
  \ 'systypes': 'sys/types',
  \ }

for h in s:headers
  execute printf('iabbrev <buffer> %sh #include <%s.h>', h, h)
endfor

for [h, f] in items(s:nested_headers)
  execute printf('iabbrev <buffer> %sh #include <%s.h>', h, f)
endfor

unlet h f

let b:ale_c_clang_options =
 \ '-fsyntax-only -std=c11 -Wall -Wno-unused-parameter -Werror'
