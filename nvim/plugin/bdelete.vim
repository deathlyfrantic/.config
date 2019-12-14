let s:e89 = 'E89: No write since last change for buffer %d (add ! to override)'

function! s:delete_current(bang) abort
  let buf = winbufnr(0)
  if getbufvar(buf, '&modified') && a:bang == ''
    return z#echoerr(s:e89, buf)
  endif
  if bufexists(0) && buflisted(0)
    buffer #
  else
    for b in reverse(getbufinfo({'buflisted': 1}))
      if b.bufnr != buf
        execute 'buffer' b.bufnr
        break
      endif
    endfor
  endif
  execute 'silent! bd'.a:bang buf
endfunction

function! s:delete_by_name(bang, name, term) abort
  let bufs = map(filter(getbufinfo({'buflisted': 1, 'bufloaded': 1}),
        \ {_, b -> b.name =~? a:name
        \     && (getbufvar(b.bufnr, '&buftype') != 'terminal' || a:term)}),
        \ {_, b -> b.bufnr})
  for b in bufs
    if getbufvar(b, '&modified') && a:bang != '!'
      return z#echoerr(s:e89, b)
    endif
  endfor
  if len(bufs)
    execute 'silent! bd'.a:bang join(bufs, ' ')
  endif
endfunction

function! s:dispatch(bang, ...) abort
  if !a:0
    return s:delete_current(a:bang)
  endif
  if tolower(a:1) == 'man'
    return s:delete_by_name('!', '^man://', 0)
  elseif tolower(a:1) =~? '^term'
    return s:delete_by_name('!', '^term://', 1)
  endif
  return s:delete_by_name(a:bang, a:1, 0)
endfunction

function! s:cmd_completion(...) abort
  return map(getbufinfo({'buflisted': 1, 'bufloaded': 1}), {_, b -> b.name}) +
        \ ['man', 'terminal']
endfunction

command! -complete=customlist,<SID>cmd_completion -nargs=* -bang -bar
      \ Bdelete call <SID>dispatch(<q-bang>, <f-args>)
