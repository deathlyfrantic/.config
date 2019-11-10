let s:separator = ' %#StatusLineSeparator#│%* '

function! s:git_status() abort
  let [branch, status] = [FugitiveHead(7), '']
  if branch == ''
    return ''
  endif
  for [sym, num] in z#zip(['+', '~', '-'], gitgutter#hunk#summary(bufnr('%')))
    let status .= num ? sym.num : ''
  endfor
  return branch.(len(status) ? '/'.status : '')
endfunction

function! s:ale_status() abort
  let [pieces, count] = [[], ale#statusline#Count(winbufnr(0))]
  for [k, v] in items({'error': count.error + count.style_error,
        \ 'warning': count.warning + count.style_warning})
    let pieces += v > 0 ? [printf('%s %s%s', v, k, v > 1 ? 's' : '')] : []
  endfor
  return join(pieces, ', ')
endfunction

function! s:set_highlight() abort
  execute printf('highlight StatusLineSeparator guifg=%s guibg=%s',
        \ z#get_color('Normal', 'bg'), z#get_color('StatusLine', 'bg'))
endfunction

function! s:add_if_nonempty(list, item) abort
  if !empty(a:item)
    call add(a:list, a:item)
  endif
endfunction

function! ActiveStatusLine() abort
  let left = ['[%n] %F%<']
  call s:add_if_nonempty(left, s:git_status())
  call s:add_if_nonempty(left, &ff != 'unix' ? &ff : '')
  call s:add_if_nonempty(left, len(&fenc) && &fenc != 'utf-8' ? &fenc : '')
  call s:add_if_nonempty(left, &filetype)
  call s:add_if_nonempty(left, &readonly ? 'readonly' : '')
  call s:add_if_nonempty(left, s:ale_status())
  let left += ['%m']
  let right = ['%=']
  call s:add_if_nonempty(right, &wrap ? 'wrap' : '')
  call s:add_if_nonempty(right, &paste ? 'paste' : '')
  call s:add_if_nonempty(right, ObsessionStatus('obsession', 'session'))
  let right += ['%l:%c%V']
  let right += ['%P']
  return join(left, s:separator) . join(right, s:separator)
endfunction

function! s:set_statusline(active) abort
  let ft = nvim_buf_get_option(0, 'filetype')
  let bt = nvim_buf_get_option(0, 'buftype')
  if z#contains(['dirvish', 'scratch', 'tagbar', 'undotree'], ft)
        \ || z#contains(['quickfix', 'terminal'], bt)
    return
  endif
  if nvim_win_get_option(0, 'previewwindow')
    let &l:statusline = '[preview] %F%=%P'
  elseif bt == 'help'
    let &l:statusline = '[help] %F%=%P'
  elseif a:active
    setlocal statusline=%!ActiveStatusLine()
  else
    let &l:statusline = '[%n] %F%<%( %m%)%=%P'
  endif
endfunction

augroup statusline
  autocmd!
  autocmd VimEnter,ColorScheme * call s:set_highlight()
  autocmd WinEnter * call <SID>set_statusline(1)
  autocmd WinLeave * call <SID>set_statusline(0)
  autocmd BufEnter * call <SID>set_statusline(winbufnr(0) == expand('<abuf>'))
  autocmd BufLeave * call <SID>set_statusline(winbufnr(0) != expand('<abuf>'))
augroup END

call <SID>set_highlight()
