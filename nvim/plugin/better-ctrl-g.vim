function! s:better_ctrl_g() abort
  let gs = GitStatus()
  let parts = strlen(gs) ? [z#rtrim(gs)] : []
  let parts += [printf('buf %d:', bufnr('%'))]
  let bn = expand('%:p')
  let parts += strlen(bn) ? [printf('"%s"', bn)] : ['"[No Name]"']
  for attr in [&filetype, &fileformat, &fileencoding]
    let parts += [printf('[%s]', attr)]
  endfor
  let parts += &modified ? ['[modified]'] : []
  let parts += &readonly ? ['[readonly]'] : []
  let [curline, lastline] = [line('.'), line('$')]
  if lastline == 1 && curline == ''
    let parts += ['--No lines in buffer--']
  else
    let parts += [printf('line %d of %d', curline, lastline)]
    let parts += [printf('--%.0f%%--', (ceil(curline) / lastline) * 100)]
    let parts += [printf('col %d', col('.'))]
  endif
  echo join(parts, ' ')
endfunction

command! File call <SID>better_ctrl_g()
nnoremap <expr> <C-g> <SID>better_ctrl_g()
