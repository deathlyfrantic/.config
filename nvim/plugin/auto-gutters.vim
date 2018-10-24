function! s:auto_gutters() abort
  for w in getwininfo()
    let bufnum = winbufnr(w.winid)
    if getbufvar(bufnum, '&buftype') =~ 'terminal\|help\|nofile'
      continue
    endif
    let tw = getbufvar(bufnum, '&textwidth')
    if tw == 0
      continue
    endif
    call setwinvar(w.winid, '&signcolumn', w.width <= tw + 2 ? 'no' : 'auto')
    call setwinvar(w.winid, '&number', w.width <= tw + 6 ? 0 : 1)
    call setwinvar(w.winid, '&foldcolumn', 0) " i never want to see this
  endfor
endfunction

augroup auto-gutters
  autocmd!
  autocmd VimEnter,VimResized,WinEnter,BufWinEnter * call s:auto_gutters()
augroup END

nnoremap <silent> <Plug>(auto-gutters) :<C-U>call <SID>auto_gutters()<CR>
