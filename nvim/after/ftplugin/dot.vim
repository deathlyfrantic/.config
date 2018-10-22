function! s:dot_to_png(...) abort
  if !executable('dot')
    echoerr 'Graphviz/Dot is not available.'
    return
  endif
  let filename = a:0 ? a:1 : expand('%:p')
  let outfile = fnamemodify(filename, ':r').'.png'
  execute '!dot' filename '-Tpng >' outfile
endfunction

command! -buffer -nargs=? DotToPng call <SID>dot_to_png(<args>)
