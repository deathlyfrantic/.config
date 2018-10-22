function! s:operator(type) abort
  let selsave = &selection
  let &selection = 'inclusive'
  if a:type =~? 'v'
    silent execute 'normal! gv'
  elseif a:type == 'line'
    silent execute "normal! '[V']"
  else
    silent execute 'normal! `[v`]'
  endif
  let l:equalprg = &equalprg
  let &equalprg = input('$ ', '', 'shellcmd')
  silent normal! =
  let &selection = selsave
  let &equalprg = l:equalprg
endfunction

nnoremap <silent> <Plug>(pipe) :set opfunc=<SID>operator<CR>g@
xnoremap <silent> <Plug>(pipe) :<C-U>call <SID>operator(visualmode())<CR>
nmap g\| <Plug>(pipe)
xmap g\| <Plug>(pipe)
