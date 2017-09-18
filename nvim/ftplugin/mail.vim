setlocal completefunc=completion#email
setlocal formatoptions-=o
setlocal formatoptions-=r
setlocal formatoptions+=w
setlocal textwidth=72
setlocal spell

" find the blank line(s) between the headers and the body
function! s:find_header_end() abort
  let l:i = 1
  let l:end = line('$')
  while l:i <= l:end
    if getline(l:i) =~ '^\s*$'
      return l:i
    endif
    let l:i += 1
  endwhile
  return -1
endfunction

" adjust 'a' formatoption based on cursor position
function! s:adjust_foa_for_headers() abort
  let l:headers_end = s:find_header_end()
  if l:headers_end == -1
    return
  endif
  if line('.') <= l:headers_end
    set formatoptions-=a
  else
    set formatoptions+=a
  endif
endfunction

autocmd InsertEnter <buffer> call s:adjust_foa_for_headers()
