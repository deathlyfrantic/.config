" set indent spacing based on filetype
command! -nargs=? SetIndent call <SID>set_indent_level(<f-args>)

function! s:set_indent_level(...)
  let l:levels = {
    \ 'xml': 2,
    \ 'html': 2,
    \ 'htmldjango': 2,
    \ 'htmljinja': 2,
    \ 'django': 2,
    \ 'vim': 2,
    \ }

  if a:0
    let l:level = a:1
  else
    let l:level = get(l:levels, &filetype, 4)
  endif

  for l:cmd in ['softtabstop', 'shiftwidth']
    execute 'setlocal '.l:cmd.'='.l:level
  endfor
endfunction
