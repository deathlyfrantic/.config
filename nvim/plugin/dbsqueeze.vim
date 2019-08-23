" super specific functionality to squeeze empty space out of vim-dadbod output
" may only apply to sql server ¯\_(ツ)_/¯
function! s:find_last_line() abort
  for i in range(1, line('$'))
    if getline(i) =~ '^\s*$'
      return i
    endif
  endfor
  throw 'Cannot find last line.'
endfunction

function! s:find_columns(lines) abort
  let cols = []
  let start = 0
  for [i, char] in z#enumerate(a:lines[1])
    if char != '-'
      let cols += [{ 'start': start, 'end': i - 1 }]
      let start = i + 1
    endif
  endfor
  return cols
endfunction

function! s:find_max_content_length(lines) abort
  let cols = s:find_columns(a:lines)
  for c in cols
    let max = len(trim(a:lines[0][c.start:c.end]))
    for i in range(2, len(a:lines) - 1)
      let length = len(trim(a:lines[i][c.start:c.end]))
      let max = max < length ? length : max
    endfor
    let c.max = max
  endfor
  return cols
endfunction

function! s:squeeze_contents(lines) abort
  let cols = reverse(s:find_max_content_length(a:lines))
  let headers = ''
  for c in cols
    let fmt = '%-'.c.max.'s'
    let headers = printf(fmt, trim(a:lines[0][c.start:c.end])) . ' ' . headers
  endfor
  let separators = ''
  for c in cols
    let separators = repeat('-', c.max) . ' ' . separators
  endfor
  let rows = []
  for line in a:lines[2:]
    let row = ''
    for c in cols
      let fmt = '%'.c.max.'s'
      let row = printf(fmt, trim(line[c.start:c.end])) . ' ' . row
    endfor
    let rows += [row]
  endfor
  return [headers] + [separators] + rows
endfunction

function! s:squeeze() abort
  let lines = getbufline(bufnr('%'), 1, s:find_last_line() - 1)
  silent! setlocal modifiable noreadonly
  call setline(1, s:squeeze_contents(lines))
  silent! setlocal nomodifiable readonly nomodified
endfunction

command! DBSqueeze :call <SID>squeeze()<CR>
