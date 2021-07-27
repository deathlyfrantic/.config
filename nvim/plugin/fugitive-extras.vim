" this is a modified version of vim-fugitive-blame-ext by Tom McDonald
" see: https://github.com/tommcdo/vim-fugitive-blame-ext
let s:subj_cmd = 'git --git-dir=%s show -s --pretty=format:%%s %s'
let s:full_cmd = 'git --git-dir=%s show -s --format=medium --color=never %s'
let s:popup_window = -1

function! s:log_message(commit)
  if a:commit =~ '^0\+$'
    return {'subj': '(Not Committed Yet)', 'full': ''}
  endif
  if !has_key(b:blame_messages, a:commit)
    let subj = system(printf(s:subj_cmd, b:git_dir, a:commit))
    let full = systemlist(printf(s:full_cmd, b:git_dir, a:commit))
    let b:blame_messages[a:commit] = {'subj': subj, 'full': full}
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
  let blame = s:log_message(line)
  echo s:truncate_message(blame.subj)
endfunction

function! s:close_popup() abort
  if s:popup_window != -1
    silent! call nvim_win_close(s:popup_window, v:true)
    let s:popup_window = -1
  endif
endfunction

function! s:popup()
  call s:close_popup()
  let line = substitute(getline('.'), '\v^\^?([a-z0-9]+).*$', '\1', '')
  let blame = s:log_message(line)
  let s:popup_window = z#popup(blame.full)
  autocmd CursorMoved,BufLeave,BufWinLeave <buffer> ++once call <SID>close_popup()
endfunction

augroup fugitive-extras-blame
  autocmd!
  autocmd BufReadPost,BufNewFile *.fugitiveblame
        \ let b:blame_messages = get(b:, 'blame_messages', {})
  autocmd BufEnter,CursorMoved *.fugitiveblame call <SID>show_log_message()
  autocmd FileType fugitiveblame nnoremap <buffer> Q <Cmd>call <SID>popup()<CR>
augroup END
