function! s:spaced_parens() abort
  let l:col = col('.')
  if l:col <= 1
    return
  endif
  let l:prev_char = getline('.')[l:col-2] " why does this need to be 2? O_o
  let l:pairs = get(g:, 'spaced_pairs', {'(': ')', '{': '}'})
  for [l, r] in items(l:pairs)
    if (v:char == r && l:prev_char != l && l:prev_char !~ '\s') ||
      \ (v:char !~ '\s' && v:char != r && l:prev_char == l)
      let v:char = ' '.v:char
      break
    endif
  endfor
endfunction

function! s:spaced_parens_switch(on) abort
  execute printf('augroup spaced-parens-buf-%s', bufnr('%'))
    autocmd!
    if a:on
      autocmd InsertCharPre <buffer> call <SID>spaced_parens()
    endif
  augroup END
endfunction

command! SpacedParensOn call <SID>spaced_parens_switch(1)
command! SpacedParensOff call <SID>spaced_parens_switch(0)
