function! s:go_away_swap(file, swap)
  let older = getftime(a:file) < getftime(a:swap)
  let msg = 'Swap file for ' . a:file .
        \ (older ? 'exists; opening read-only' : 'older than file; deleted.')
  execute 'autocmd BufEnter * ++once call z#echowarn("'.msg.'")'
  let v:swapchoice = older ? 'o' : 'd'
endfunction

augroup swap_command
  autocmd!
  autocmd SwapExists * call s:go_away_swap(expand('<afile>'), v:swapname)
augroup END
