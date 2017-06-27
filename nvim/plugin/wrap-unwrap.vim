" handy wrap/unwrap mappings
command! -nargs=? Wrap call <SID>wrap(<f-args>)
command! Unwrap call <SID>unwrap()

function! s:wrap(...)
  let s:orig_colcol = &colorcolumn
  let s:orig_tw = &textwidth

  if a:0
    execute 'setlocal textwidth='.a:1.' colorcolumn='.a:1
  endif

  setlocal wrap linebreak
  inoremap <Up> <C-o>gk
  inoremap <Down> <C-o>gj
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
  execute 'setlocal textwidth='.s:orig_tw.' colorcolumn='.s:orig_colcol
  iunmap <Up>
  iunmap <Down>
  unmap k
  unmap gk
  unmap j
  unmap gj
  unmap $
  unmap g$
  unmap ^
  unmap g^
endfunction
