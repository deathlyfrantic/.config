function! s:dirvish_toggle() abort
  let bufs = filter(getbufinfo(),
        \ {_, b -> b.loaded && getbufvar(b.bufnr, '&ft') ==? 'dirvish'})
  if len(bufs) == 0
    35vsp +Dirvish
  else
    execute 'bd!' join(map(bufs, {_, b -> b.bufnr}))
  endif
endfunction

function! s:dirvish_open() abort
  let line = getline('.')
  if line =~? '/$'
    call dirvish#open('edit', 0)
  else
    call <SID>dirvish_toggle()
    execute 'e' line
  endif
endfunction

function! s:dirvish_autocmds() abort
  setlocal nonumber norelativenumber statusline=%F
  nnoremap <silent> <buffer> <C-r> :Dirvish %<CR>
  nnoremap <silent> <buffer> <CR> :call <SID>dirvish_open()<CR>
  nnoremap <silent> <buffer> q :call <SID>dirvish_toggle()<CR>
  silent! keeppatterns g@\v/\.[^\/]+/?$@d
  for pat in split(&wildignore, ',')
    execute printf('silent! keeppatterns g@\v/%s/?$@d', pat)
  endfor
endfunction

augroup dirvish_commands
  autocmd!
  autocmd FileType dirvish call <SID>dirvish_autocmds()
augroup END

nnoremap <silent> <Plug>(dirvish-toggle) :call <SID>dirvish_toggle()<CR>
