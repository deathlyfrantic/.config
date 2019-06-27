let s:buffer = -1
let s:file = get(s:, 'file', tempname())
let s:cmd_map = {
      \ 'files': 'open_file',
      \ 'buffers': 'open_buffer'
      \ }
let s:star_cmd_str = ''

augroup star
  autocmd!
  autocmd ColorScheme * let s:star_cmd_str = ''
augroup END

function! s:color(group, attr) abort
  return synIDattr(synIDtrans(hlID(a:group)), a:attr)
endfunction

function! s:find_cmd() abort
  for ignore in findfile('.gitignore', '.;', -1)
    if len(filter(readfile(ignore), {_, line -> line == '*'})) > 0
      return 'git ls-files'
    endif
  endfor
  let open_files = map(filter(getbufinfo(),
        \ {_, b -> b.listed && b.loaded && b.name != ''
        \       && getbufvar(b.bufnr, '&bt') != 'nofile'}),
        \ {_, b -> fnamemodify(b.name, ':p:~:.')})
  return printf('rg --files %s', join(map(open_files, {_, f -> '-g !'.f})))
endfunction

function! s:star_cmd() abort
  if s:star_cmd_str == ''
    let colors = {
          \ 'color-selected-bg': s:color('StatusLine', 'bg'),
          \ 'color-matched-selected-fg': s:color('Comment', 'fg'),
          \ 'color-matched-fg': s:color('String', 'fg'),
          \ }
    let s:star_cmd_str = 'star '
          \ .join(map(items(colors), {_, c -> printf('--%s=%s', c[0], c[1])}))
  endif
  return s:star_cmd_str
endfunction

function! s:cmd(mode) abort
  let cmd = printf('(cd %s && %%s | %s > %s)', z#find_project_dir(),
        \ s:star_cmd(), s:file)
  if a:mode == 'files'
    return printf(cmd, s:find_cmd())
  elseif a:mode == 'buffers'
    let bufs = map(filter(getbufinfo(), {_, b -> b.listed && b.name != ''}),
          \ {_, b -> fnamemodify(b.name, ':p:~:.')})
    let echo_cmd = printf('echo "%s"', join(bufs, '\n'))
    return printf(cmd, echo_cmd)
  endif
endfunction

function! s:open_buffer(b) abort
  execute 'buffer' a:b
endfunction

function! s:open_file(f) abort
  if filereadable(a:f)
    execute 'edit' z#find_project_dir().a:f
  endif
endfunction

function! s:on_exit(mode, job_id, exit_code, event) abort
  if s:buffer != -1
    silent! execute 'bdelete!' s:buffer
    let s:buffer = -1
  endif
  if a:exit_code == 0
    if filereadable(s:file)
      let f = readfile(s:file)[0]
      call call(printf('s:%s', get(s:cmd_map, a:mode, 'open_file')), [f])
    endif
  endif
endfunction

function! s:open_star_buffer(mode) abort
  let height = min([10, &lines / 3])
  execute 'botright' height 'split'
  enew
  let &l:statusline='[Star ('.z#find_project_dir().')] '.s:find_cmd()
  let cmd = s:cmd(a:mode)
  set nomodifiable nobuflisted buftype=nofile
  let s:buffer = bufnr('%')
  call termopen(cmd, {'on_exit': function('s:on_exit', [a:mode])})
  silent! execute 'resize' line('$')
  startinsert
endfunction

function! s:star(...) abort
  let mode = a:0 ? a:1 : 'files'
  if !has_key(s:cmd_map, mode)
    let mode = 'files'
  endif
  call s:open_star_buffer(mode)
endfunction

function! s:cmd_completion(...) abort
  return keys(s:cmd_map)
endfunction

command! -nargs=? -complete=customlist,<SID>cmd_completion
      \ Star call s:star(<f-args>)

nnoremap <C-p> :Star<CR>
nnoremap g<C-p> :Star buffers<CR>
