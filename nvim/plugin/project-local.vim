function! s:source_local_vimrc()
  " prevent this from breaking fugitive's Gdiff, don't run on dirvish etc
  if expand('%') =~? 'fugitive://' || index(['help', 'nofile'], &buftype) != -1
    return
  endif
  let l:dir = expand('%:p:h')
  " apply settings from lowest dir to highest, so most specific settings are
  " applied latest
  for l:vimrc in reverse(findfile('.vimrc', l:dir.';', -1))
    if filereadable(l:vimrc)
      execute 'source '.l:vimrc
    endif
  endfor
endfunction

autocmd BufNewFile,BufReadPre * call <SID>source_local_vimrc()
