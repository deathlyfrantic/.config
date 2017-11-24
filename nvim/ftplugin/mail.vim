setlocal completefunc=completion#email
setlocal formatoptions-=o
setlocal formatoptions-=r
setlocal formatoptions+=w
setlocal textwidth=72
setlocal spell

" find the blank line(s) between the headers and the body
function! s:find_header_end() abort
  let i = 1
  while i <= line('$')
    if getline(i) =~ '^\s*$'
      return i
    endif
    let i += 1
  endwhile
  return -1
endfunction

" adjust 'a' formatoption based on cursor position
function! s:adjust_foa_for_headers() abort
  let headers_end = s:find_header_end()
  if headers_end == -1
    return
  endif
  if line('.') <= headers_end
    set formatoptions-=a
  else
    set formatoptions+=a
  endif
endfunction

autocmd InsertEnter <buffer> call <SID>adjust_foa_for_headers()
