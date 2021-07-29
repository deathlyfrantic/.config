function! z#popup(text) abort
  let buf = nvim_create_buf(v:false, v:true)
  let array_text = type(a:text) == v:t_string ? split(a:text, '\n') : a:text
  let text = [''] + map(copy(array_text), {_, t -> ' ' .. t .. ' '}) + ['']
  call nvim_buf_set_lines(buf, 0, -1, v:true, text)
  let opts = {'relative': 'cursor', 'height': len(text), 'style': 'minimal',
        \ 'focusable': v:false}
  let opts.width = max(map(copy(text), {_, v -> len(v)}))
  let opts.anchor = (screenrow() > (&lines / 2) ? 'S' : 'N')
        \ . (screencol() > (&columns / 2) ? 'E' : 'W')
  let opts.row = opts.anchor[0] == 'N' ? 1 : 0
  let opts.col = opts.anchor[1] == 'E' ? 0 : 1
  let win = nvim_open_win(buf, 0, opts)
  call nvim_win_set_option(win, 'colorcolumn', '0')
  return win
endfunction

function! z#echohl(hl, ...) abort
  if !a:0
    throw 'A message is required for this function.'
  endif
  let msg = a:0 > 1 ? call('printf', a:000) : a:1
  let l:echo = 'WarningMsg\|ErrorMsg' =~? a:hl ? 'echomsg' : 'echo'
  execute 'echohl' a:hl
  try
    execute l:echo 'msg'
  finally
    echohl None
  endtry
endfunction

function! z#echowarn(...) abort
  call call('z#echohl', ['WarningMsg'] + a:000)
endfunction

function! z#any(items, f) abort
  for item in a:items
    if a:f(item)
      return 1
    endif
  endfor
  return 0
endfunction

function! z#char_before_cursor() abort
  let col = col('.') - 2
  return col < 0 ? '' : getline('.')[col]
endfunction
