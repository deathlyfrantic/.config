function! s:go_away_swap(file, swap)
  if getftime(a:file) < getftime(a:swap)
    let l:choice = 'o'
    let l:msg = 'Swap file for %s exists; opening read-only.'
  else
    let l:choice = 'd'
    let l:msg = 'Swap file for %s older than file; deleted.'
  endif
  call s:delayed_message(printf(l:msg, a:file))
  let v:swapchoice = l:choice
endfunction

function! s:delayed_message(msg)
  augroup swap_delayed_message
    autocmd!
    execute printf("autocmd BufEnter * call z#echowarn('%s')", a:msg)
    autocmd BufEnter * autocmd! swap_delayed_message
  augroup END
endfunction

augroup swap_command
  autocmd!
  autocmd SwapExists * call s:go_away_swap(expand('<afile>'), v:swapname)
augroup END
