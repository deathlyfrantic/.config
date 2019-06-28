setlocal completefunc=completion#email
setlocal formatoptions-=o
setlocal formatoptions-=r
setlocal formatoptions+=w
setlocal textwidth=72
setlocal spell

let b:header_end = -1

" find the blank line(s) between the headers and the body
function! s:update_header_end() abort
  let i = 1
  while i <= line('$')
    if getline(i) =~ '^\s*$'
      let b:header_end = i
      return
    endif
    let i += 1
  endwhile
  let b:header_end = -1
endfunction

" adjust 'a' formatoption based on cursor position
function! s:adjust_foa_for_headers() abort
  if line('.') <= b:header_end
    set formatoptions-=a
  else
    set formatoptions+=a
  endif
endfunction

autocmd InsertLeave <buffer> call <SID>update_header_end()
autocmd CursorMoved <buffer> call <SID>adjust_foa_for_headers()

call <SID>update_header_end()
