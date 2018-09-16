let s:test_buffer = -1

function! s:makefile_test() abort
  if !filereadable('Makefile')
    throw 'no `Makefile` found'
  endif
  let contents = readfile('Makefile')
  for line in contents
    if line =~? '^test:'
      return 'make test'
    endif
  endfor
  throw 'no `test` make target found in `Makefile`'
endfunction

function! s:rust() abort
  if !executable('cargo')
    throw '`cargo` does not exist or is not executable'
  endif
  return 'cargo test'
endfunction

function! s:python() abort
  return executable('pytest') ? 'pytest' : 'python3 -m unittest'
endfunction

function! s:javascript() abort
  let package_json = findfile('package.json', ';')
  if package_json == ''
    throw 'no `package.json` file found'
  endif
  let package = json_decode(readfile(package_json))
  let scripts = get(package, 'scripts', {})
  if !empty(get(scripts, 'test'))
    return 'npm test'
  endif
  throw '`package.json` has no `test` command defined'
endfunction

function! s:sh() abort
  if !executable('shunit2')
    throw '`shunit2` does not exist or is not executable'
  endif
  if !filereadable('test.sh')
    throw '`test.sh` is not readable'
  endif
  return 'shunit2 test.sh'
endfunction

function! s:new_test_buffer() abort
  let s:test_buffer = bufnr('%')
  autocmd BufDelete <buffer> let s:test_buffer = -1
  nnoremap <silent> <buffer> q :bd!<CR>
endfunction

function! s:load_or_create_buffer() abort
  if bufexists(s:test_buffer)
    execute printf('b%s', s:test_buffer)
  else
    enew
    call s:new_test_buffer()
    normal G
  endif
endfunction

function! s:new_test_window() abort
  let height = &lines / 3
  execute printf('botright %ssp', height)
  call s:load_or_create_buffer()
endfunction

function! s:ensure_test_window() abort
  let test_buf_windows = win_findbuf(s:test_buffer)
  if len(test_buf_windows) < 1
    call s:new_test_window()
  endif
endfunction

function! s:close_test_buffer(...)
  execute printf('silent bd! %s', s:test_buffer)
endfunction

function! s:on_term_exit(job_id, exit_code, event)
  if a:exit_code == 0
    call timer_start(1000, function('s:close_test_buffer'))
    call z#echohl('GitGutterAdd', 'Tests pass. (Test runner exit code was 0.)')
  else
    call s:scroll_to_end()
  endif
endfunction

function! s:scroll_to_end() abort
  let current_window = win_getid()
  for window in win_findbuf(s:test_buffer)
    call win_gotoid(window)
    normal G
  endfor
  call win_gotoid(current_window)
endfunction

function! s:run_tests(cmd) abort
  call s:ensure_test_window()
  let current_window = win_getid()
  call win_gotoid(win_findbuf(s:test_buffer)[0])
  set nomodified
  call termopen(a:cmd, {'on_exit': function('s:on_term_exit')})
  call win_gotoid(current_window)
endfunction

function! s:get_normalized_filetype() abort
  " account for 'javascript.jsx'
  return &ft =~? 'javascript' ? 'javascript' : &ft
endfunction

function! s:orchestrate_tests() abort
  let test_cmds = []
  let errs = []
  try
    let Runner = has_key(b:, 'test_command')
      \ ? {-> b:test_command}
      \ : function(printf('s:%s', s:get_normalized_filetype()))
    let test_cmds = [Runner()]
  catch /^Vim\%((\a\+)\)\=:E700/ " runner doesn't exist
    let errs += [printf("No tests available for filetype '%s'", &ft)]
  catch " runner didn't return a valid command
    let errs += [printf('Test runner failed: %s', v:exception)]
  endtry
  try
    let test_cmds += [s:makefile_test()]
  catch
    let errs += [printf('%s', v:exception)]
  endtry
  let current_window = win_getid()
  if len(test_cmds)
    call s:run_tests(test_cmds[0])
  else
    call z#echoerr(join(errs, ' and '))
  endif
  call win_gotoid(current_window)
endfunction

command! RunTests call <SID>orchestrate_tests()
nnoremap <Plug>(run-tests) :RunTests<CR>
