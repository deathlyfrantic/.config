function! s:save_file(num) abort
  return expand(printf('$XDG_DATA_HOME/nvim/scratch-%s.txt', a:num))
endfunction

function! s:bufname(num) abort
  return printf('__Scratch%s__', a:num)
endfunction

function! s:height() abort
  return min([10, &lines / 3])
endfunction

function! s:read(num) abort
  let pos = getcurpos()
  execute '%delete _'
  call setline(1, readfile(s:save_file(a:num)))
  call setpos('.', pos)
  let b:ftime = localtime()
endfunction

function! s:write(num) abort
  call writefile(getline(1, '$'), s:save_file(a:num))
  let b:ftime = localtime()
endfunction

function! s:new_buffer(num) abort
  execute 'topleft' s:height() 'new' s:bufname(a:num)
  setlocal filetype=scratch bufhidden=hide nobuflisted buftype=nofile
  setlocal formatoptions-=o formatoptions-=r
  setlocal noswapfile textwidth=0 winfixheight winfixwidth
  setlocal textwidth=0 winfixheight winfixwidth
  let &l:statusline = '[Scratch/' .. a:num .. ']%=%l,%c%V%6P'
  setlocal wrap linebreak
  nnoremap <silent> <buffer> q <C-w>q
  nnoremap <silent> <buffer> R :call <SID>read()<CR>
  nnoremap <silent> <buffer> <leader>s <C-w>p
  execute 'augroup scratch-' .. a:num
    autocmd!
    execute 'autocmd WinLeave <buffer> call s:close_window(' .. a:num .. ')'
  augroup END
endfunction

function! s:close_window(num) abort
  if !filereadable(s:save_file(a:num))
        \ || get(b:, 'ftime') >= getftime(s:save_file(a:num))
    call s:write(a:num)
    execute bufwinnr(s:bufname(a:num)) 'close'
  elseif filereadable(s:save_file(a:num))
        \ && get(b:, 'ftime') < getftime(s:save_file(a:num))
    if confirm('Scratch buffer changed since loading. Write anyway?',
          \ "&Yes\n&No", 2) == 1
      call s:write(a:num)
      execute bufwinnr(s:bufname(a:num)) 'close'
    endif
  endif
endfunction

function! s:open_buffer(num) abort
  let bnum = bufnr(s:bufname(a:num))
  if bnum == -1
    call s:new_buffer(a:num)
    if filereadable(s:save_file(a:num))
      call s:read(a:num)
    endif
  else
    let wnum = bufwinnr(bnum)
    if wnum == -1
      execute 'topleft' s:height() 'split +buffer' .. bnum
    else
      execute bnum 'wincmd w'
    endif
    if filereadable(s:save_file(a:num))
          \ && getftime(s:save_file(a:num)) > get(b:, 'ftime')
      call s:read(a:num)
    endif
  endif
endfunction

function! s:selection(num) abort
  let [contents, type] = [getreg('"'), getregtype('"')]
  normal! y
  call s:open_buffer(a:num)
  execute '%delete _'
  put
  normal! ggdd
  call setreg('"', contents, type)
endfunction

command! ScratchBuffer call <SID>scratch()

nnoremap <silent> <leader>s <Cmd>call <SID>open_buffer(v:count)<CR>
xnoremap <silent> <leader>s <Cmd>call <SID>selection(v:count)<CR>
