function! s:move_bwd_by_word() abort
  let [pos, cmd] = [getcmdpos(), getcmdline()]
  if pos != 1
    let saw_letter = 0
    let i = pos - 1
    while i > 0
      let i -= 1
      let saw_letter = saw_letter || cmd[i] =~ '\w'
      if cmd[i] =~ '\W' && saw_letter
        let i += 1
        break
      endif
    endwhile
    call setcmdpos(i + 1)
  endif
  return cmd
endfunction

function! s:move_fwd_by_word() abort
  let [pos, cmd] = [getcmdpos(), getcmdline()]
  let cmdlen = len(cmd)
  if pos < cmdlen
    let saw_letter = 0
    let i = pos - 1
    while i < cmdlen
      let i += 1
      let saw_letter = saw_letter || cmd[i] =~ '\w'
      if cmd[i] =~ '\W' && saw_letter
        break
      endif
    endwhile
    call setcmdpos(i + 1)
  endif
  return cmd
endfunction

function! s:delete_word() abort
  let [pos, cmd] = [getcmdpos(), getcmdline()]
  let end = pos
  while cmd[end] =~ '\W' && end < len(cmd)
    let end += 1
  endwhile
  while end < len(cmd)
    if cmd[end] =~ '\W'
      break
    endif
    let end += 1
  endwhile
  return pos == 1 ? cmd[end:-1] : cmd[0:pos - 2] . cmd[end:-1]
endfunction

function! s:kill_line() abort
  let [pos, cmd] = [getcmdpos(), getcmdline()]
  return pos == 1 ? '' : cmd[:pos-2]
endfunction

cnoremap <C-a> <Home>
cnoremap <C-b> <Left>
cnoremap <C-d> <Delete>
cnoremap <C-e> <End>
cnoremap <C-f> <Right>
cnoremap <C-g> <C-c>
cnoremap <C-k> <C-\>e <SID>kill_line()<CR>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>
cnoremap <M-b> <C-\>e <SID>move_bwd_by_word()<CR>
cnoremap <M-d> <C-\>e <SID>delete_word()<CR>
cnoremap <M-f> <C-\>e <SID>move_fwd_by_word()<CR>
