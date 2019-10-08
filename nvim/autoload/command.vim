function! command#buf_delete(bufnum, bang) abort
  if getbufvar(a:bufnum, '&modified') && a:bang == ''
    let m = 'E89: No write since last change for buffer %d (add ! to override)'
    call z#echoerr(m, a:bufnum)
    return
  endif
  if bufexists(0) && buflisted(0)
    buffer #
  else
    for buf in reverse(getbufinfo({'buflisted': 1}))
      if buf.bufnr != a:bufnum
        execute 'buffer' buf.bufnr
        break
      endif
    endfor
  endif
  execute 'bd'.a:bang a:bufnum
endfunction

function! command#close_floating_windows() abort
  for winid in map(getwininfo(), {_, v -> v.winid})
    if nvim_win_get_config(winid).relative isnot ''
      call nvim_win_close(winid, v:true)
    endif
  endfor
endfunction

function! command#source_local_vimrc(bang) abort
  if a:bang != '!' && (expand('<afile>') =~? 'fugitive://'
        \ || z#contains(['help', 'nofile'], getbufvar(expand('<abuf>'), '&bt')))
    return
  endif
  " apply settings from lowest dir to highest, so most specific are applied last
  for vimrc in reverse(findfile('.vimrc', expand('<afile>:p:h').';', -1))
    execute 'silent! source' vimrc
  endfor
endfunction

function! command#close_man_pages() abort
  let bufs = filter(getbufinfo(), {_, b -> b.listed && b.name =~? '^man://'})
  execute 'bd!' join(map(bufs, {_, b -> b.bufnr}), ' ')
endfunction
