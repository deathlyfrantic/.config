let g:qf_preview = 1
let s:popup_window = -1

function! s:file_info() abort
  let matches = matchlist(getline('.'), '^\(.\+\)|\(\d\+\) col \(\d\+\)|')
  if len(matches) < 3
    throw 'Unable to determine line number from quickfix line'
  endif
  let rv = {'filename': matches[1], 'line': matches[2] + 0}
  if len(matches) > 3
    let rv.col = matches[3] + 0
  endif
  return rv
endfunction

function! s:highlight(line) abort
  if exists('w:highlight')
    call matchdelete(w:highlight)
  endif
  let w:highlight = matchaddpos('Visual', [a:line])
  execute 'normal!' a:line.'G'
endfunction

function! s:get_lines_and_pos(info) abort
  let context = &previewheight / 2
  let lines = readfile(a:info.filename, '',
        \ max([a:info.line + context, &previewheight]))
  if len(lines) < &previewheight + 1
    let line = a:info.line
    let lines = lines
  elseif len(lines) < a:info.line + context
    let lines_after = len(lines) - a:info.line
    let line = &previewheight - lines_after + 1
    let lines = lines[-&previewheight - 1:-1]
  else
    let line = context + 1
    let lines = lines[-&previewheight - 1:-1]
  endif
  return [lines, line]
endfunction

function! s:preview_contents(info) abort
  let [lines, line] = s:get_lines_and_pos(a:info)
  let s:popup_window = z#popup(lines)
  let width = max(map(copy(lines), {_, v -> len(v)}))
  call nvim_buf_add_highlight(nvim_win_get_buf(s:popup_window), -1,
        \ 'PmenuSel', line, 1, width + 1)
endfunction

function! s:close_popup() abort
  if s:popup_window != -1
    silent! call nvim_win_close(s:popup_window, v:true)
    let s:popup_window = -1
  endif
endfunction

function! s:preview() abort
  call s:close_popup()
  if line('.') == get(b:, 'qf_preview_line', -1)
    return
  endif
  let b:qf_preview_line = line('.')
  try
    let info = s:file_info()
  catch
    " don't do anything on errors; if we can't find the file/line info from the
    " quickfix line then it's probably not a file we can open and preview; just
    " swallow it
    return
  endtry
  call s:preview_contents(info)
  autocmd CursorMoved,BufLeave,BufWinLeave <buffer> ++once call <SID>close_popup()
endfunction

augroup quickfix-preview
  autocmd!
  autocmd FileType qf nnoremap <buffer> Q <Cmd>call <SID>preview()<CR>
augroup END
