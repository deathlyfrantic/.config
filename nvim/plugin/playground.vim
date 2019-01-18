let s:pg_output_buffer = -1

let s:grounds = {
  \ 'c': {
  \   'extension': 'c',
  \   'command': 'cc %s -o $TMPDIR/a.out && $TMPDIR/a.out',
  \   'template': [
  \     '#include <stdio.h>',
  \     '#include <stdlib.h>',
  \     '#include <string.h>',
  \     '',
  \     'int main(void) {',
  \     '  %#;',
  \     '  return EXIT_SUCCESS;',
  \     '}'
  \   ],
  \ },
  \ 'rust': {
  \   'extension': 'rs',
  \   'command': 'rustc %s -o $TMPDIR/a.out && $TMPDIR/a.out',
  \   'template': [
  \      'fn main() {',
  \      '    %#;',
  \      '}',
  \   ]
  \ },
  \ 'python': {
  \   'extension': 'py',
  \   'command': 'python3 %s',
  \   'template': [],
  \ },
  \ 'javascript': {
  \   'extension': 'js',
  \   'command': 'node %s',
  \   'template': [],
  \ }
  \ }

function! s:new_pg_output_buffer() abort
  let s:pg_output_buffer = bufnr('%')
  set nobuflisted
  autocmd BufDelete <buffer> let s:pg_output_buffer = -1
  nnoremap <silent> <buffer> q :bd!<CR>
endfunction

function! s:load_or_create_buffer() abort
  if bufexists(s:pg_output_buffer)
    execute 'b' s:pg_output_buffer
  else
    enew
    call s:new_pg_output_buffer()
    normal G
  endif
endfunction

function! s:new_pg_window() abort
  let window = filter(getwininfo(), {i, v -> v.winnr == winnr()})[0]
  let height = window.height / 3
  execute 'belowright' height 'sp'
  call s:load_or_create_buffer()
endfunction

function! s:ensure_pg_window() abort
  if len(win_findbuf(s:pg_output_buffer)) < 1
    call s:new_pg_window()
  endif
endfunction

function! s:delete_output_buffer() abort
  if s:pg_output_buffer != -1
    silent execute 'bd!' s:pg_output_buffer
  endif
endfunction

function! s:scroll_to_end(...) abort
  let current_window = win_getid()
  for window in win_findbuf(s:pg_output_buffer)
    call win_gotoid(window)
    normal G
  endfor
  call win_gotoid(current_window)
endfunction

function! s:run_pg(cmd) abort
  call s:ensure_pg_window()
  let current_window = win_getid()
  call win_gotoid(win_findbuf(s:pg_output_buffer)[0])
  set nomodified
  call termopen(a:cmd, {'on_exit': function('s:scroll_to_end')})
  call win_gotoid(current_window)
endfunction

function! s:open_pg_buffer(ground) abort
  execute 'e' printf('%s.%s', tempname(), a:ground.extension)
  let command = printf(a:ground.command, @%)
  execute 'autocmd BufWritePost <buffer> call s:run_pg("'.command.'")'
  autocmd BufDelete <buffer> call s:delete_output_buffer()
  call setline(1, a:ground.template)
  call feedkeys("ggI\<C-f>")
endfunction

function! s:get_normalized_filetype() abort
  " account for 'javascript.jsx'
  return &ft =~? 'javascript' ? 'javascript' : &ft
endfunction

function! s:open_pg(...) abort
  if a:0
    let l:ft = a:1
  else
    let l:ft = s:get_normalized_filetype()
  endif
  if !has_key(s:grounds, l:ft)
    call z#echoerr('No playground information found for filetype "%s"', l:ft)
    return
  endif
  call s:open_pg_buffer(s:grounds[l:ft])
endfunction

command! -nargs=? Playground call s:open_pg(<f-args>)
