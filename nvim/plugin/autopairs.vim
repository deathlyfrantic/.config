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

function! s:add_pair(left) abort
  " don't add pair if next char is a word char, i.e. if we type ( here:
  "   |foo
  " don't add )
  return z#char_after_cursor() =~ '\h'
        \ ? a:left
        \ : a:left.s:pairs[a:left]."\<Left>"
endfunction

function! s:quote(q) abort
  if z#char_after_cursor() == a:q
    return "\<Right>"
  endif
  if a:q != "'" || z#char_before_cursor() !~ '\h'
    " don't add closing ' if in a word, like in a contraction
    return a:q.a:q."\<Left>"
  endif
  return a:q
endfunction

function! s:close(right) abort
  return z#char_after_cursor() == a:right ? "\<Right>" : a:right
endfunction

function! s:backspace() abort
  return z#char_after_cursor() is get(s:qpairs, z#char_before_cursor())
        \ ? "\<Delete>\<Backspace>"
        \ : "\<Backspace>"
endfunction

function! s:enter() abort
  return z#char_after_cursor() is get(s:pairs, z#char_before_cursor())
        \ ? "\<Enter>\<Esc>O"
        \ : "\<Enter>"
endfunction

function! s:angle() abort
  " since < is overloaded, we only want to auto-close it if we're in a generic
  " parameter, and the heuristic we're using for that is the previous character
  " is not whitespace. i.e. auto-close this: `struct Foo<'a>`, do not auto-close
  " this: `if x < y`
  return z#char_before_cursor() =~ '\s' ? '<' : "<>\<Left>"
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
  " rust and typescript generic parameters
  autocmd FileType rust,typescript inoremap <expr> <buffer> < <SID>angle() |
        \ inoremap <expr> <buffer> > <SID>close('>')
  " vim comments start with "
  autocmd FileType vim inoremap <buffer> " "
augroup END
