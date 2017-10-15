function! utils#uglify_js(...) abort
  if !executable('uglifyjs')
    echoerr 'UglifyJS is not available.'
    return
  endif
  let l:file = a:0 ? a:1 : expand('%:p')
  if l:file =~? '.min.js'
    return
  endif
  execute '!uglifyjs '.l:file.' -mo '.fnamemodify(l:file, ':r').'.min.'.fnamemodify(l:file, ':e')
endfunction

function! utils#dot_to_png(...) abort
  if !executable('dot')
    echoerr 'Graphviz/Dot is not available.'
    return
  endif
  let l:file = a:0 ? a:1 : expand('%:p')
  let l:output = fnamemodify(l:file, ':r') . '.png'
  let l:cmd = '!dot '.l:file.' -Tpng > '.l:output
  execute l:cmd
endfunction

function! utils#compile_sass(...) abort
  if !(executable('sass') || executable('sassc'))
    echoerr 'Sass is not available.'
    return
  endif
  let l:file = a:0 ? a:1 : expand('%:p')
  if fnamemodify(l:file, ':t')[0] == '_'
    return
  endif
  execute '!sass -t compressed '.l:file.' '.fnamemodify(l:file, ':r').'.css'
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

function! utils#rfc(arg) abort
  if !executable('rfc')
    echoerr 'RFC is not available.'
    return
  endif
  call utils#preview(system('rfc '.a:arg))
endfunction
