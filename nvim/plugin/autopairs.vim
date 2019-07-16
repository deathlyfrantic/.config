let s:pairs = {
      \ '(': ')',
      \ '[': ']',
      \ '{': '}',
      \ }

let s:qpairs = extend(deepcopy(s:pairs), {
      \ '"': '"',
      \ "'": "'",
      \ '`': '`'
      \ })

function! s:next_char() abort
  return getline('.')[col('.') - 1]
endfunction

function! s:add_pair(left) abort
  return s:next_char() =~ '\h' ? a:left : a:left.s:pairs[a:left]."\<Left>"
endfunction

function! s:quote(q) abort
  if s:next_char() == a:q
    return "\<Right>"
  endif
  if a:q != "'" || completion#char_before_cursor() !~ '\h'
    " don't add closing ' if in a word, like in a contraction
    return a:q.a:q."\<Left>"
  endif
  return a:q
endfunction

function! s:close(right) abort
  return s:next_char() == a:right ? "\<Right>" : a:right
endfunction

function! s:backspace() abort
  return s:next_char() is get(s:qpairs, completion#char_before_cursor())
        \ ? "\<Delete>\<Backspace>"
        \ : "\<Backspace>"
endfunction

function! s:enter() abort
  return s:next_char() is get(s:pairs, completion#char_before_cursor())
        \ ? "\<Enter>\<Esc>O"
        \ : "\<Enter>"
endfunction

for [left, right] in items(s:pairs)
  execute 'inoremap <expr>' left '<SID>add_pair("'.left.'")'
  execute 'inoremap <expr>' right '<SID>close("'.right.'")'
endfor

inoremap <expr> ' <SID>quote("'")
inoremap <expr> " <SID>quote('"')
inoremap <expr> ` <SID>quote('`')

inoremap <expr> <Backspace> <SID>backspace()

" enter mapping is set up this way to chain with endwise
inoremap <expr> <Plug>autopairsCR <SID>enter()
imap <Enter> <Plug>autopairsCR

augroup autopairs
  autocmd!
  " rust lifetime specifiers are of the form 'a
  autocmd FileType rust inoremap <buffer> ' '
  " vim comments start with "
  autocmd FileType vim inoremap <buffer> " "
augroup END
