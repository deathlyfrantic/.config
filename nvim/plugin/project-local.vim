function! s:source_local_vimrc()
  " prevent this from breaking fugitive's Gdiff, don't run on dirvish etc
  if expand('%') =~? 'fugitive://' || 'help\|nofile' =~? &bt
    return
  endif
  let l:dir = expand('%:p:h')
  " apply settings from lowest dir to highest,
  " so most specific settings are applied latest
  for l:vimrc in reverse(findfile('.vimrc', l:dir.';', -1))
    if filereadable(l:vimrc)
      execute printf('source %s', l:vimrc)
    endif
  endfor
endfunction

autocmd BufNewFile,BufReadPre * nested call <SID>source_local_vimrc()
