" this is a modified version of vim-fugitive-blame-ext by Tom McDonald
" see: https://github.com/tommcdo/vim-fugitive-blame-ext
let s:subj_cmd = 'git --git-dir=%s show -s --pretty=format:%%s %s'
let s:body_cmd = 'git --git-dir=%s show -s --pretty=format:%%b %s'

function! s:log_message(commit)
  if a:commit =~ '^0\+$'
    return '(Not Committed Yet)'
  endif
  if !has_key(b:blame_messages, a:commit)
    let subj = system(printf(s:subj_cmd, b:git_dir, a:commit))
    let body = systemlist(printf(s:body_cmd, b:git_dir, a:commit))
    let b:blame_messages[a:commit] = {'subj': subj, 'body': body}
  endif
  return b:blame_messages[a:commit]
endfunction

function! s:truncate_message(message)
  let offset = 2
  if &ruler == 1 && (&laststatus == 0 || (&laststatus == 1 && winnr('$') == 1))
    " Statusline is not visible, so the ruler is. Its width is either 17
    " (default) or defined in 'rulerformat'.
    let offset += str2nr(get(matchlist(&ruf, '^%\(\d\+\)('), 1, '17')) + 1
  endif
  if &showcmd
    " Width of showcmd seems to always be 11.
    let offset += 11
  endif
  let maxwidth = &columns - offset
  if strlen(a:message) > maxwidth
    return a:message[0:(maxwidth - 3)] . '...'
  else
    return a:message
  endif
endfunction

function! s:show_log_message()
  let line = substitute(getline('.'), '\v^\^?([a-z0-9]+).*$', '\1', '')
  redraw
  let blame = s:log_message(line)
  echo s:truncate_message(blame.subj)
  if len(blame.body)
    call z#preview(blame.body)
  else
    pclose!
  endif
endfunction

augroup fugitive-extras-blame
  autocmd!
  autocmd BufReadPost,BufNewFile *.fugitiveblame
    \ let b:blame_messages = get(b:, 'blame_messages', {})
  autocmd BufEnter,CursorMoved *.fugitiveblame call <SID>show_log_message()
augroup END
