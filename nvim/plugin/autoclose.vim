let s:pairs = { '(': ')', '[': ']', '{': '}'}
let s:closers = { ')': '(', ']': '[', '}': '{' }
let s:no_semi_lines = {
      \ 'javascript': [
      \   '^\(if\|while\|switch\|for\) (.*) {$',
      \   '^} \(else\|else if (.*)\) {$',
      \   '^function.*{',
      \   '^\%[static ]\%[async \*]\w\+(.*) {',
      \   '^\%[[gs]et ]\w\+(.*) {',
      \   '^do {$',
      \ ],
      \ 'rust': [
      \   '^\%[pub\%[(\(crate\|super\|self\|in [0-9A-Za-z_:]*\))] ]\(fn\|enum\|mod\|struct\|trait\).*{$',
      \   '^} \(else\|else if .*\) {$',
      \   '^\(impl\|unsafe\|match\|if\|while\).*{$',
      \ ],
      \ 'c': [
      \   '^\(if\|while\|switch\|for\) (.*) {$',
      \   '^} \(else\|else if (.*)\) {$',
      \   '^\w*\s*\**\s*\w*(.*) {$',
      \   '^do {$',
      \ ]
      \ }

function! s:semi() abort
  let ft = &filetype == 'typescript' ? 'javascript' : &filetype
  if !has_key(s:no_semi_lines, ft)
    return ''
  endif
  let line = trim(getline('.'))
  return z#any(s:no_semi_lines[ft], {test -> line =~ test}) ? '' : ';'
endfunction

function! s:in_string(line, col) abort
  return z#any(synstack(a:line, a:col),
        \ {id -> synIDattr(synIDtrans(id), 'name') =~? 'string'})
endfunction

function! s:remove_last(stack, c) abort
  let i = len(a:stack) - 1
  while i > -1
    if a:stack[i] == a:c
      return remove(a:stack, i)
    endif
    let i -= 1
  endwhile
endfunction

function! s:indent(lnr) abort
  return len(matchstr(getline(a:lnr), '^\s*'))
endfunction

function! s:should_close(end) abort
  let start = join(map(copy(a:end), {_, v -> s:closers[v]}), '')
  let end = join(reverse(copy(a:end)), '')
  let m = searchpair(start, '', end, 'Wn')
  return !(m > 0 && s:indent(m) == s:indent(line('.')))
  m <= 0 || s:indent(m) != s:indent(line('.'))
endfunction

function! s:enter() abort
  if !has_key(s:pairs, trim(getline('.'))[-1:])
    " don't do anything if the (trimmed) line doesn't end with a left pair item
    return "\<Enter>"
  endif
  let stack = []
  for [i, c] in z#enumerate(getline('.'), 1)
    if !s:in_string(line('.'), i)
      if has_key(s:pairs, c)
        let stack += [s:pairs[c]]
      elseif has_key(s:closers, c)
        call s:remove_last(stack, c)
      endif
    endif
  endfor
  let slash = &filetype == 'vim' ? '\ ' : ''
  return len(stack) && s:should_close(stack)
        \ ? "\<Enter>".slash.join(reverse(stack), '').s:semi()."\<C-o>O".slash
        \ : "\<Enter>"
endfunction

inoremap <expr> <Plug>autocloseCR <SID>enter()
imap <Enter> <Plug>autocloseCR
