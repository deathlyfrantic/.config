function! s:preview_markdown(...) abort
  if !executable('cmark')
    echoerr 'Unable to convert Markdown (cmark is not available).'
    return
  endif
  let filename = a:0 ? a:1 : expand('%:p')
  let outfile = tempname().'.html'
  execute '!cmark' filename '>' outfile '; open -g' outfile
endfunction

command! -buffer -nargs=? PreviewMarkdown call <SID>preview_markdown(<args>)

setlocal spell
setlocal wrapmargin=0
