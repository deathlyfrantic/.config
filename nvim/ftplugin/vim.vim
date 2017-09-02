setlocal foldmethod=marker
iabbrev fn function

if expand('%:t') == '.vimrc' && expand('%:h') != $HOME && line('$') == 1 && getline(1) == ""
  call setline(2, 'augroup local_vimrc')
  call setline(3, '  autocmd!')
  call setline(4, 'augroup END')
  call cursor(1, 1)
endif
