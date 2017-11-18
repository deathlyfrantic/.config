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

function! s:allowed_unused_parameter() abort
  let l:args = get(b:, 'neomake_c_clang_args', neomake#makers#ft#c#clang().args)
  let l:unused = '-Wno-unused-parameter'
  if index(l:args, l:unused) == -1
    let l:args = add(l:args, l:unused)
  endif
  let b:neomake_c_clang_args = l:args
endfunction

command! -bar -buffer AllowUnusedParameter call <SID>allowed_unused_parameter()
