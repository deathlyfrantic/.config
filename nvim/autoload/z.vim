function! z#uglify_js(...) abort
  if !executable('uglifyjs')
    echoerr 'UglifyJS is not available.'
    return
  endif
  let l:file = a:0 ? a:1 : expand('%:p')
  if l:file =~? '.min.js'
    return
  endif
  execute printf('!uglifyjs %s -mo %s.min.%s',
    \ l:file,
    \ fnamemodify(l:file, ':r')
    \ fnamemodify(l:file, ':e')
    \ )
endfunction

function! z#dot_to_png(...) abort
  if !executable('dot')
    echoerr 'Graphviz/Dot is not available.'
    return
  endif
  let l:file = a:0 ? a:1 : expand('%:p')
  let l:output = printf('%s.png', fnamemodify(l:file, ':r'))
  execute printf('!dot %s -Tpng > %s', l:file, l:output)
endfunction

function! z#compile_sass(...) abort
  if !(executable('sass') || executable('sassc'))
    echoerr 'Sass is not available.'
    return
  endif
  let l:file = a:0 ? a:1 : expand('%:p')
  if fnamemodify(l:file, ':t')[0] == '_'
    return
  endif
  execute printf('!sass -t compressed %s %s.css',
    \ l:file,
    \ fnamemodify(l:file, ':r')
    \ )
endfunction

function! z#preview_markdown(...) abort
  if !executable('md2html')
    echoerr 'Unable to convert Markdown (md2html is not available).'
    return
  endif
  let l:file = a:0 ? a:1 : expand('%:p')
  let l:output = printf('%s%s.html', $TMPDIR, fnamemodify(l:file, ':t:r'))
  execute printf('!md2html %s %s; open %s', l:file, l:output, l:output)
endfunction

function! z#rfc(arg) abort
  if !executable('rfc')
    echoerr 'RFC is not available.'
    return
  endif
  call z#preview(system(printf('rfc %s', a:arg)))
endfunction

function! z#preview(text) abort
  if &previewwindow
    return
  endif
  let l:win = win_getid()
  let l:winview = winsaveview()
  pclose!
  execute printf('%dnew', &previewheight)
  set previewwindow noswapfile nobuflisted buftype=nofile
  let l:text = (type(a:text) == type([])) ? a:text : split(a:text, '\n')
  call append(0, l:text)
  call cursor(1, 1)
  call win_gotoid(l:win)
  call winrestview(l:winview)
endfunction

function! z#chomp(s, ...) abort
  let sep = a:0 ? a:000 : ['\r\n', '\r', '\n']
  let regex = printf('\%%(%s\)$', join(sep, '\|'))
  return substitute(a:s, regex, '', '')
endfunction

function! z#sys_chomp(s) abort
  return z#chomp(system(a:s))
endfunction

function! z#enumerate(l, ...) abort
  let start = a:0 ? a:1 : 0
  let collection = (type(a:l) == type('')) ? split(a:l, '\zs') : a:l
  return map(collection, {i, v -> [(i + start), v]})
endfunction

function! z#zip(a, b) abort
  let collection = len(a:a) > len(a:b) ? a:a[:len(a:b)-1] : a:a
  return map(collection, {i, v -> [v, a:b[i]]})
endfunction
