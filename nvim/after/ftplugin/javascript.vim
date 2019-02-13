function! s:uglify_js(...) abort
  if !executable('uglifyjs')
    echoerr 'UglifyJS is not available.'
    return
  endif
  let filename = a:0 ? a:1 : expand('%:p')
  if filename =~? '\.min\.js$'
    return
  endif
  let [root, ext] = [fnamemodify(filename, ':r'), fnamemodify(filename, ':e')]
  execute '!uglifyjs' filename '-mo' root.'.min.'.ext
endfunction

command! -buffer -nargs=? UglifyJS call <SID>uglify_js(<args>)

setlocal cinoptions-=(0
setlocal cinoptions-=:0
setlocal cinoptions+=l1

iabbrev <buffer> != !==
iabbrev <buffer> == ===
iabbrev <buffer> fn function

" don't use clangformat for js
let b:neoformat_enabled_javascript = get(b:, 'neoformat_enabled_javascript',
      \ filter(neoformat#formatters#javascript#enabled(),
      \ {i, v -> v != 'clangformat'}))
