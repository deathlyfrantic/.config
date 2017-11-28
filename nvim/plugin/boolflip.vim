function! s:match_case(orig, new) abort
  if a:orig ==# tolower(a:orig)
    return tolower(a:new)
  elseif a:orig ==# toupper(a:orig)
    return toupper(a:new)
  else
    return toupper(a:new[0]) . tolower(a:new[1:])
  endif
endfunction

function! s:bool_flip() abort
  let l:pairs = [
    \ ['true', 'false'],
    \ ['yes', 'no'],
    \ ['on', 'off'],
    \ ]
  let l:word = expand('<cWORD>')
  for l:pair in l:pairs
    for l:token in l:pair
      if l:word =~? l:token
        let l:new = l:pair[!index(l:pair, l:token)]
        execute 'normal! ciw'.<SID>match_case(l:word, l:new)
        return
      endif
    endfor
  endfor
endfunction

command! BoolFlip call <SID>bool_flip()
nnoremap <silent> Q :BoolFlip<CR>
