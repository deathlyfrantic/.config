function! s:compile_sass(...) abort
  if !(executable('sass') || executable('sassc'))
    echoerr 'Sass is not available.'
    return
  endif
  let filename = a:0 ? a:1 : expand('%:p')
  if fnamemodify(filename, ':t')[0] == '_'
    return
  endif
  let outfile = fnamemodify(filename, ':r').'.css'
  execute '!sass -t compressed' filename outfile
endfunction

command! -buffer -nargs=? CompileSass call <SID>compile_sass(<args>)

augroup scss-ftplugin
  autocmd!
  autocmd BufWritePost <buffer> CompileSass
augroup END
