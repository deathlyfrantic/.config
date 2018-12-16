function! z#preview(text) abort
  if &previewwindow
    return
  endif
  let l:win = win_getid()
  let l:winview = winsaveview()
  pclose!
  execute 'topleft' &previewheight 'new'
  set previewwindow noswapfile nobuflisted buftype=nofile
  nnoremap <silent> <buffer> q :pclose!<CR>
  nnoremap <silent> <buffer> <C-c> :pclose!<CR>
  let l:text = type(a:text) == v:t_list ? a:text : split(a:text, '\n')
  call append(0, l:text)
  call cursor(1, 1)
  call win_gotoid(l:win)
  call winrestview(l:winview)
endfunction

function! z#chomp(s, ...) abort
  let sep = a:0 ? a:000 : ['\r\n', '\r', '\n']
  let regex = printf('\%%(%s\)*$', join(sep, '\|'))
  return substitute(a:s, regex, '', '')
endfunction

function! z#sys_chomp(s) abort
  return z#chomp(system(a:s))
endfunction

function! z#enumerate(l, ...) abort
  let start = a:0 ? a:1 : 0
  let collection = type(a:l) == v:t_string ? split(a:l, '\zs') : a:l
  return map(collection, {i, v -> [(i + start), v]})
endfunction

function! z#zip(a, b) abort
  let collection = len(a:a) > len(a:b) ? a:a[:len(a:b)-1] : a:a
  return map(collection, {i, v -> [v, a:b[i]]})
endfunction

function! z#flatten(list) abort
  let rv = []
  for item in a:list
    let rv += type(item) == v:t_list ? z#flatten(item) : [item]
  endfor
  return rv
endfunction

function! z#echohl(hl, msg) abort
  let l:msg = type(a:msg) == v:t_list ? a:msg : [a:msg]
  let l:echo = 'WarningMsg\|ErrorMsg' =~? a:hl ? 'echomsg' : 'echo'
  execute 'echohl' a:hl
  try
    for m in l:msg
      execute l:echo 'm'
    endfor
  finally
    echohl None
  endtry
endfunction

function! z#echowarn(msg) abort
  call z#echohl('WarningMsg', a:msg)
endfunction

function! z#echoerr(msg) abort
  call z#echohl('ErrorMsg', a:msg)
endfunction

function! z#multisub(expr, pat, sub, ...)
  let flags = a:0 ? a:1 : ''
  let pat = type(a:pat) == v:t_list ? a:pat : [a:pat]
  if type(a:sub) == v:t_list
    let sub = a:sub
  else
    let sub = []
    for _ in pat
      let sub += [a:sub]
    endfor
  endif
  let rv = a:expr
  for [search, replace] in z#zip(pat, sub)
    let rv = substitute(rv, search, replace, flags)
  endfor
  return rv
endfunction

function! z#ltrim(s) abort
  return substitute(a:s, '^[[:space:]]*', '', '')
endfunction

function! z#rtrim(s) abort
  return substitute(a:s, '[[:space:]]*$', '', '')
endfunction

function! z#trim(s) abort
  return z#ltrim(z#rtrim(a:s))
endfunction
