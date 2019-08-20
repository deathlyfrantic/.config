let s:test_buffer = -1

function! s:get_match_lines(start, num) abort
  if a:num == 0
    return getline(a:start)
  endif
  return join(getline(a:start, a:start + a:num), "\n")
endfunction

function! s:find_nearest_test(pattern, atom) abort
  let num_lines = len(split(a:pattern, '\\n')) - 1
  let l:match = matchlist(s:get_match_lines(line('.'), num_lines), a:pattern)
  if len(l:match) > 0
    return l:match[a:atom]
  endif
  let before = search(a:pattern, 'bnW')
  if before != 0
    return matchlist(s:get_match_lines(before, num_lines), a:pattern)[a:atom]
  endif
  let after = search(a:pattern, 'nW')
  if after != 0
    return matchlist(s:get_match_lines(after, num_lines), a:pattern)[a:atom]
  endif
  return ''
endfunction

function! s:makefile_test() abort
  let makefile = findfile('Makefile', ';')
  if makefile == ''
    throw 'no `Makefile` found'
  endif
  let contents = readfile(makefile)
  let makefile_dir = fnamemodify(makefile, ':h')
  for line in contents
    if line =~? '^test:'
      return printf('(cd %s && make test)', makefile_dir)
    endif
  endfor
  throw 'no `test` make target found in `Makefile`'
endfunction

function! s:rust(selection) abort
  if !executable('cargo')
    throw '`cargo` does not exist or is not executable'
  endif
  " change to source dir in case file is in a subproject, but strip off the
  " trailing 'src' component e.g. /code/project/src/main.rs -> /code/project
  let cmd = printf('(cd %s && cargo test)', expand('%:p:h:h'))
  if a:selection == 'nearest'
    let mod_tests_line = search('^mod tests {$', 'n')
    if mod_tests_line == 0
      return cmd
    endif
    let nearest = s:find_nearest_test('#\[test]\n\s*fn\s\+\(\w*\)(', 1)
    return cmd[:-2] . printf(' %s)', nearest)
  elseif a:selection == 'file'
    return cmd[:-2] . printf(' %s::)', expand('%:t:r'))
  endif
  return cmd
endfunction

function! s:python_pytest(selection) abort
  let filename = expand('%:p')
  if a:selection == 'nearest'
    let nearest = s:find_nearest_test('^\s*def \(\w*\)(', 1)
    return printf('pytest %s::%s', filename, nearest)
  elseif a:selection == 'file'
    return printf('pytest %s', filename)
  endif
  return 'pytest'
endfunction

function! s:python(selection) abort
  if executable('pytest')
    return s:python_pytest(a:selection)
  endif
  let pipfile = findfile('Pipfile', ';')
  if pipfile != ''
    for line in pipfile
      if line =~? '^pytest'
        return printf('pipenv run %s', s:python_pytest(a:selection))
      endif
    endfor
  endif
  return 'python3 -m unittest'
endfunction

function! s:javascript_mocha(selection) abort
  let cmd = 'npx mocha -- spec '.expand('%:p')
  if a:selection == 'nearest'
    let test = s:find_nearest_test('^\s*\(it\|describe\)(["'']\(.*\)["''],', 2)
    let escaped = substitute(test, '\([{\[()\]}]\)', '\\\1', 'g')
    return cmd.' --grep='.shellescape(escaped)
  elseif a:selection == 'file'
    return cmd
  endif
  return 'npm test'
endfunction

function! s:javascript(selection) abort
  let package_json = findfile('package.json', ';')
  if package_json == ''
    throw 'no `package.json` file found'
  endif
  let package = json_decode(readfile(package_json))
  let scripts = get(package, 'scripts', {})
  let test_cmd = get(scripts, 'test')
  if test_cmd =~ 'mocha'
    return s:javascript_mocha(a:selection)
  endif
  if !empty(test_cmd)
    return 'npm test'
  endif
  throw '`package.json` has no `test` command defined'
endfunction

function! s:sh(...) abort
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
  set nobuflisted
  autocmd BufDelete <buffer> let s:test_buffer = -1
  nnoremap <silent> <buffer> q :bd!<CR>
endfunction

function! s:load_or_create_buffer() abort
  if bufexists(s:test_buffer)
    execute 'b' s:test_buffer
  else
    enew
    call s:new_test_buffer()
    normal G
  endif
endfunction

function! s:new_test_window() abort
  let height = &lines / 3
  execute 'botright' height 'sp'
  call s:load_or_create_buffer()
endfunction

function! s:ensure_test_window() abort
  if len(win_findbuf(s:test_buffer)) < 1
    call s:new_test_window()
  endif
endfunction

function! s:close_test_buffer(...)
  silent! execute 'bd!' s:test_buffer
endfunction

function! s:on_term_exit(close, job_id, exit_code, event)
  if a:exit_code == 0
    if a:close
      call timer_start(1000, function('s:close_test_buffer'))
    endif
    call z#echohl('GitGutterAdd', 'Tests pass. (Test runner exit code was 0.)')
  else
    call s:scroll_to_end()
  endif
endfunction

function! s:scroll_to_end(...) abort
  let current_window = win_getid()
  for window in win_findbuf(s:test_buffer)
    call win_gotoid(window)
    normal G
  endfor
  call win_gotoid(current_window)
endfunction

function! s:run_tests(cmd, close) abort
  call s:ensure_test_window()
  let current_window = win_getid()
  call win_gotoid(win_findbuf(s:test_buffer)[0])
  set nomodified
  call termopen(a:cmd, {'on_exit': function('s:on_term_exit', [a:close])})
  call win_gotoid(current_window)
endfunction

function! s:get_normalized_filetype() abort
  " account for 'javascript.jsx', also for this script typescript == javascript
  return &ft =~? 'javascript\|typescript' ? 'javascript' : &ft
endfunction

function! s:orchestrate_tests(selection, bang) abort
  let test_cmds = []
  let errs = []
  try
    let Runner = has_key(b:, 'test_command')
          \ ? {-> b:test_command}
          \ : function(printf('s:%s', s:get_normalized_filetype()))
    let test_cmds = [Runner(a:selection)]
  catch /^Vim\%((\a\+)\)\=:E700/ " runner doesn't exist
    let errs += [printf("No tests available for filetype '%s'", &ft)]
  catch " runner didn't return a valid command
    let errs += [printf('Test runner failed: %s', v:exception)]
  endtry
  try
    let test_cmds += [s:makefile_test()]
  catch
    let errs += [v:exception]
  endtry
  let current_window = win_getid()
  if len(test_cmds)
    call s:run_tests(test_cmds[0], a:bang != '!')
  else
    call z#echoerr(join(errs, ' and '))
  endif
  call win_gotoid(current_window)
endfunction

command! -bang RunTestNearest call <SID>orchestrate_tests('nearest', <q-bang>)
command! -bang RunTestFile call <SID>orchestrate_tests('file', <q-bang>)
command! -bang RunTestSuite call <SID>orchestrate_tests('all', <q-bang>)

nmap <silent> <leader>t :RunTestNearest<CR>
nmap <silent> <leader>T :RunTestFile<CR>
nmap <silent> <leader><C-t> :RunTestSuite<CR>

nmap <silent> g<leader>t :RunTestNearest!<CR>
nmap <silent> g<leader>T :RunTestFile!<CR>
nmap <silent> g<leader><C-t> :RunTestSuite!<CR>
