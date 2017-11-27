" handy wrap/unwrap mappings
command! -nargs=? Wrap call <SID>wrap(<f-args>)
command! Unwrap call <SID>unwrap()

function! s:wrap(...)
  let b:orig_cc = &colorcolumn
  let b:orig_tw = &textwidth
  if a:0
    execute printf('setlocal textwidth=%s colorcolumn=%s', a:1, a:1)
  endif
  setlocal wrap linebreak
  noremap k gk
  noremap gk k
  noremap j gj
  noremap gj j
  noremap $ g$
  noremap g$ $
  noremap ^ g^
  noremap g^ ^
endfunction

function! s:unwrap()
  setlocal nowrap nolinebreak
  execute printf('setlocal textwidth=%s colorcolumn=%s', b:orig_tw, b:orig_cc)
  unmap k
  unmap gk
  unmap j
  unmap gj
  unmap $
  unmap g$
  unmap ^
  unmap g^
endfunction
