" addons for dirvish
nnoremap <silent> <Plug>(dirvish-toggle) :<C-u>call <SID>dirvish_toggle()<CR>

function! s:dirvish_toggle() abort
  let i = 1
  let dirvish_already_open = 0
  while i <= bufnr('$')
    if bufexists(i) && bufloaded(i) && getbufvar(i, '&filetype') ==? 'dirvish'
      let dirvish_already_open = 1
      execute printf('%dbd!', i)
    endif
    let i += 1
  endwhile
  if !dirvish_already_open
    35vsp +Dirvish
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
  nnoremap <silent> <buffer> <CR> :<C-u> call <SID>dirvish_open()<CR>
  nnoremap <silent> <buffer> q :<C-u>call <SID>dirvish_toggle()<CR>
  silent! keeppatterns g@\v/\.[^\/]+/?$@d
  for pat in get(g:, 'ignore_patterns', [])
    execute printf('silent! keeppatterns g@\v/%s/?$@d', pat)
  endfor
  call fugitive#detect(@%)
endfunction

augroup dirvish_commands
  autocmd!
  autocmd FileType dirvish call <SID>dirvish_autocmds()
augroup END
