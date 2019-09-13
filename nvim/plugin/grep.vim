function! s:operator(type) abort
  let regsave = @@
  let selsave = &selection
  if a:type =~? 'v\|line\|'
    silent execute 'normal! y'
  else
    silent execute 'normal! `[v`]y'
  endif
  let search = @@
  let &selection = selsave
  let @@ = regsave
  call <SID>grep(search)
endfunction

function! s:grep(search) abort
  execute 'silent grep!' a:search
  let num_results = len(getqflist())
  if num_results == 0
    redraw!
    echo 'No matches found.'
  else
    execute 'copen' min([num_results, 10])
    let w:quickfix_title = 'grep "'.a:search.'"'
  endif
endfunction

if executable('rg')
  let &grepprg = printf("rg -F -S -H --no-heading --vimgrep %s '$*'",
        \ join(map(split(&wildignore, ','), {_, v -> printf("-g '!%s'", v)})))
  set grepformat=%f:%l:%c:%m
endif

command! -nargs=+ Grep call <SID>grep(<q-args>)

execute 'nnoremap g/ :Grep '
nnoremap g/% :Grep <C-R>=expand('%:p:t:r')<CR><CR>
nnoremap <silent> <Plug>(Grep) :set opfunc=<SID>operator<CR>g@
xnoremap <silent> <Plug>(Grep) <Cmd>call <SID>operator(mode())<CR>
nmap gs <Plug>(Grep)
xmap gs <Plug>(Grep)
