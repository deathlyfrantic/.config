function! s:operator(type) abort
  let selsave = &selection
  let &selection = 'inclusive'
  if a:type !~? 'v\|line'
    silent execute 'normal! `[v`]'
  endif
  let l:equalprg = &equalprg
  let &equalprg = input('$ ', '', 'shellcmd')
  silent normal! =
  let &selection = selsave
  let &equalprg = l:equalprg
endfunction

nnoremap <silent> <Plug>(pipe) :set opfunc=<SID>operator<CR>g@
xnoremap <silent> <Plug>(pipe) <Cmd>call <SID>operator(visualmode())<CR>
nmap g\| <Plug>(pipe)
xmap g\| <Plug>(pipe)
