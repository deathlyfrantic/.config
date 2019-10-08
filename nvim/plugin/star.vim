let s:buffer = -1
let s:file = get(s:, 'file', tempname())
let s:cmd_map = {
      \ 'files': 'open_file',
      \ 'buffers': 'open_buffer',
      \ 'all': 'open_file',
      \ }
let s:star_cmd_str = ''

augroup star
  autocmd!
  autocmd ColorScheme * let s:star_cmd_str = ''
augroup END

function! s:find_cmd(mode) abort
  for ignore in findfile('.gitignore', '.;', -1)
    if len(filter(readfile(ignore), {_, line -> line == '*'})) > 0
      return 'git ls-files'
    endif
  endfor
  let open_files = a:mode == 'all' ? [] :
        \  map(filter(getbufinfo({'buflisted': 1, 'bufloaded': 1}),
        \ {_, b -> b.name != '' && getbufvar(b.bufnr, '&bt') != 'nofile'}),
        \ {_, b -> fnamemodify(b.name, ':p:~:.')})
  return printf('rg --files %s', join(map(
        \ open_files, {_, f -> '-g !'.shellescape(escape(f, ' ['))})))
endfunction

function! s:star_cmd() abort
  if s:star_cmd_str == ''
    let colors = {
          \ 'color-selected-bg': z#get_color('StatusLine', 'bg'),
          \ 'color-matched-selected-fg': z#get_color('Comment', 'fg'),
          \ 'color-matched-fg': z#get_color('String', 'fg'),
          \ }
    let s:star_cmd_str = 'star '
          \ .join(map(items(colors), {_, c -> printf('--%s=%s', c[0], c[1])}))
  endif
  return s:star_cmd_str
endfunction

function! s:cmd(mode) abort
  let cmd = printf('(cd %s && %%s | %s > %s)',
        \ shellescape(z#find_project_dir()), s:star_cmd(), s:file)
  if a:mode == 'files' || a:mode == 'all'
    return printf(cmd, s:find_cmd(a:mode))
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
  let file = escape(z#find_project_dir().a:f, ' [')
  if filereadable(file)
    execute 'edit' file
  endif
endfunction

function! s:on_exit(mode, job_id, exit_code, event) abort
  wincmd p
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
  let current_buffer = bufnr('%')
  let height = min([10, &lines / 3])
  execute 'botright' height 'split'
  enew
  let cmd = s:cmd(a:mode)
  setlocal nomodifiable nobuflisted buftype=nofile
  let s:buffer = bufnr('%')
  call termopen(cmd, {'on_exit': function('s:on_exit', [a:mode])})
  let &l:statusline = printf('[Star(%s)] %s', z#find_project_dir()[:-2],
        \ a:mode == 'buffers' ? 'open buffers' : s:find_cmd(a:mode))
  silent! execute 'resize' line('$')
  startinsert
endfunction

function! s:star(...) abort
  let mode = a:0 && has_key(s:cmd_map, a:1) ? a:1 : 'files'
  call s:open_star_buffer(mode)
endfunction

function! s:cmd_completion(...) abort
  return keys(s:cmd_map)
endfunction

command! -nargs=? -complete=customlist,<SID>cmd_completion
      \ Star call s:star(<f-args>)

nnoremap <C-p>  :Star<CR>
nnoremap g<C-p> :Star all<CR>
nnoremap g<C-b> :Star buffers<CR>
