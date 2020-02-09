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
  for vimrc in reverse(findfile('.vimrc', expand('<afile>:p:h') .. ';', -1))
    execute 'silent! source' vimrc
  endfor
endfunction
