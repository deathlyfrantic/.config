function! s:source_local_vimrc()
  " prevent this from breaking fugitive's Gdiff
  if expand('%') =~? 'fugitive://'
    return
  endif

  let l:dir = expand('%:p:h')
  let l:vimrc = findfile('.vimrc', l:dir.';')

  if filereadable(l:vimrc)
    execute 'source '.l:vimrc
  endif
endfunction

autocmd BufNewFile,BufReadPost * call <SID>source_local_vimrc()
