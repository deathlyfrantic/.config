" addons for dirvish
nnoremap <silent> <Plug>(dirvish-toggle) :<C-u>call <SID>dirvish_toggle()<CR>

function! s:dirvish_toggle() abort
  let bufs = filter(getbufinfo(),
    \ {_, b -> b.loaded && getbufvar(b.bufnr, '&ft') ==? 'dirvish'}) 
  if len(bufs) == 0
    35vsp +Dirvish
  else
    execute printf('bd! %s', join(map(bufs, {_, b -> b.bufnr})))
  endif
endfunction

function! s:dirvish_open() abort
  let line = getline('.')
  if line =~? '/$'
    call dirvish#open('edit', 0)
  else
    call <SID>dirvish_toggle()
    execute printf('e %s', line)
  endif
endfunction

function! s:dirvish_autocmds() abort
  setlocal nonumber norelativenumber statusline=%F
  nnoremap <silent> <buffer> <C-r> :<C-u>Dirvish %<CR>
  nnoremap <silent> <buffer> <CR> :<C-u>call <SID>dirvish_open()<CR>
  nnoremap <silent> <buffer> q :<C-u>call <SID>dirvish_toggle()<CR>
  silent! keeppatterns g@\v/\.[^\/]+/?$@d
  for pat in get(g:, 'ignore_patterns', [])
    execute printf('silent! keeppatterns g@\v/%s/?$@d', pat)
  endfor
endfunction

augroup dirvish_commands
  autocmd!
  autocmd FileType dirvish call <SID>dirvish_autocmds()
augroup END
