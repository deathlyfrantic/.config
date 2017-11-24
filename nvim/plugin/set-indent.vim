" set indent spacing based on filetype
command! -nargs=? SetIndent call <SID>set_indent_level(<f-args>)

function! s:set_indent_level(...)
  let levels = {
    \ 'xml': 2,
    \ 'html': 2,
    \ 'htmldjango': 2,
    \ 'htmljinja': 2,
    \ 'django': 2,
    \ 'vim': 2,
    \ }
  let level = (a:0) ? a:1 : get(levels, &filetype, 4)
  execute printf('setlocal softtabstop=%d', level)
  execute printf('setlocal shiftwidth=%d', level)
endfunction
