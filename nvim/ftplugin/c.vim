setlocal commentstring=//%s

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

for s:h in s:headers
  execute printf("iabbrev <buffer> %sh #include <%s.h>", s:h, s:h)
endfor
