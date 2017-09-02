function! s:spaced_parens() abort
  let l:col = col('.')
  if l:col == 1
    return
  endif
  let l:prev_char = getline('.')[l:col-2] " why does this need to be 2? O_o
  if v:char == ')' && l:prev_char != '(' && l:prev_char !~ '\s'
    let v:char = ' )'
  elseif v:char !~ '\s' && v:char != ')' && l:prev_char == '('
    let v:char = ' '.v:char
  endif
endfunction

function! s:spaced_parens_on() abort
  let l:group = 'spaced-parens-buf-'.bufnr('%')
  execute 'augroup '.l:group
    autocmd!
    autocmd InsertCharPre <buffer> call <SID>spaced_parens()
  augroup END
endfunction

function! s:spaced_parens_off() abort
  let l:group = 'spaced-parens-buf-'.bufnr('%')
  execute 'augroup '.l:group
    autocmd!
  augroup END
endfunction

command! SpacedParensOn call <SID>spaced_parens_on()
command! SpacedParensOff call <SID>spaced_parens_off()
