function! utils#uglify_js(...) abort
  let l:file = a:0 ? a:1 : expand('%:p')
  if executable('uglifyjs') && l:file !~? '.min.js'
    execute '!uglifyjs '.l:file.' -mo '.fnamemodify(l:file, ':r').'.min.'.fnamemodify(l:file, ':e')
  endif
endfunction

function! utils#dot_to_png(...) abort
  let l:file = a:0 ? a:1 : expand('%:p')
  let l:output = fnamemodify(l:file, ':r') . '.png'
  let l:cmd = '!dot '.l:file.' -Tpng > '.l:output
  execute l:cmd
endfunction

function! utils#preview(text) abort
  if &previewwindow
    return
  endif
  let l:win = win_getid()
  let l:winview = winsaveview()
  pclose!
  execute &previewheight."new"
  set previewwindow noswapfile nobuflisted buftype=nofile
  let l:text = (type(a:text) == type([])) ? a:text : split(a:text, "\n")
  call append(0, l:text)
  call cursor(1, 1)
  call win_gotoid(l:win)
  call winrestview(l:winview)
endfunction
