setlocal cinoptions+=l1
let s:headers = [
      \ 'assert',
      \ 'ctype',
      \ 'inttypes',
      \ 'limits',
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

if expand('%:e') == 'h' && line('$') && getline(1) == ''
  let guard = printf('%s_%s', toupper(fnamemodify(getcwd(), ':t')),
        \ substitute(toupper(expand('%:t')), '[^A-Z0-9]', '_', 'g'))
  call setline(1, ['#ifndef ' .. guard, '#define ' .. guard, '', '', '',
        \ '#endif /* end of include guard: ' .. guard .. ' */'])
  call cursor(4, 1)
endif
