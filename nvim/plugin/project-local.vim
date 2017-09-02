function! s:source_local_vimrc()
  " prevent this from breaking fugitive's Gdiff
  if expand('%') =~? 'fugitive://' || index(['help', 'nofile'], &buftype) != -1
    return
  endif
  let l:dir = expand('%:p:h')
  for l:vimrc in findfile('.vimrc', l:dir.';', -1)
    if get(b:, 'stop_sourcing_vimrcs', 0)
      let b:stop_sourcing_vimrcs = 0
      return
    endif
    if filereadable(l:vimrc)
      execute 'source '.l:vimrc
    endif
  endfor
endfunction

autocmd BufNewFile,BufReadPre * call <SID>source_local_vimrc()
command! TurnOffProject let b:stop_sourcing_vimrcs = 1
