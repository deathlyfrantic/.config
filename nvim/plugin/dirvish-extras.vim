function! s:dirvish_toggle() abort
  let bufs = filter(getbufinfo({'bufloaded': 1}),
        \ {_, b -> getbufvar(b.bufnr, '&ft') ==? 'dirvish'})
  if len(bufs) == 0
    35vsp +Dirvish
  else
    execute 'bdelete!' join(map(bufs, {_, b -> b.bufnr}))
  endif
endfunction

function! s:dirvish_open() abort
  let line = getline('.')
  if line =~? '/$'
    call dirvish#open('edit', 0)
  else
    call <SID>dirvish_toggle()
    execute 'edit' line
  endif
endfunction

function! s:dirvish_autocmds() abort
  setlocal nonumber norelativenumber statusline=%F
  nnoremap <silent> <buffer> <C-r> <Cmd>Dirvish %<CR>
  nnoremap <silent> <buffer> <CR>  <Cmd>call <SID>dirvish_open()<CR>
  nnoremap <silent> <buffer> q     <Cmd>call <SID>dirvish_toggle()<CR>
  silent! keeppatterns g@\v/\.[^\/]+/?$@d
  for pat in split(&wildignore, ',')
    execute 'silent! keeppatterns g@\v/' .. pat .. '/?$@d'
  endfor
endfunction

augroup dirvish_commands
  autocmd!
  autocmd FileType dirvish call <SID>dirvish_autocmds()
augroup END

nnoremap <silent> <Plug>(dirvish-toggle) <Cmd>call <SID>dirvish_toggle()<CR>
