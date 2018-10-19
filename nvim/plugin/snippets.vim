let s:marker = '%#;'
" marker shape is very deliberate - it needs to end in ';' so c/rust/etc
" indenting isn't thrown off, and it can't start with '#' because c assumes that
" is a preprocessor directive and removes all indentation. further, the '%#'
" portion echoes vim's '\%#' regex atom which matches cursor position.
let s:snippets = get(s:, 'snippets', {})

function! s:available_snippets() abort
  return extend(copy(s:snippets), b:snippets)
endfunction

function! snippets#available_snippets() abort
  let snippets = {}
  for snippet in values(s:available_snippets())
    let snippets[snippet.lhs] = snippet.desc
  endfor
  return snippets
endfunction

function! s:snippet(...) abort
  if a:0
    let [rhs, lhs, expr] = [a:000[-1], a:000[-2], count(a:000, '<expr>') > 0]
    let snippet = {'rhs': rhs, 'lhs': lhs, 'expr': expr, 'desc': rhs}
    call s:add_snippet(count(a:000, '<buffer>') > 0 ? 's' : 'b', snippet)
  else
    call s:list_snippets()
  endif
endfunction

function! s:add_snippet(scope, snippet) abort
  let snippets = a:scope =~ 's\|g' ? s:snippets : b:snippets
  let snippets[a:snippet.lhs] = a:snippet
endfunction

function! s:list_snippets() abort
  for [gb, scope] in z#zip(['g', 'b'], [s:, b:])
    for s in values(get(scope, 'snippets', {}))
      echo printf('%s  %-20s%-8s%s', gb, s.lhs, s.expr ? '<expr>' : '', s.desc)
    endfor
  endfor
endfunction

function! s:jump(ins) abort
  let keys = a:ins ? repeat("\<Delete>", len(s:marker)) : len(s:marker).'s'
  if search(s:marker, 'W')
    call feedkeys(keys)
  endif
endfunction

function! s:parse_snippet_line(line) abort
  let snippet = {}
  let tmp = substitute(a:line, '^snippet\s*', '', '')
  let snippet.expr = tmp =~ '^<expr>'
  let tmp = substitute(tmp, '^<expr>\s*', '', '')
  let snippet.lhs = matchstr(tmp, '^\w*')
  let tmp = substitute(tmp, '^\w*\s*', '', '')
  let tmp = z#multisub(tmp, ['^["'']', '["'']$'], '', '')
  let snippet.desc = tmp
  return snippet
endfunction

function! s:parse_snippet_file(file) abort
  let [snippets, snippet, in_snippet, body] = [[], {}, 0, []]
  for line in readfile(a:file)
    if line =~? '^snippet'
      let in_snippet = 1
      let snippet = s:parse_snippet_line(line)
    elseif line =~? '^endsnippet' && in_snippet
      let snippet.rhs = join(body, "\n")
      let snippets += [snippet]
      let [in_snippet, body, snippet] = [0, [], {}]
    elseif in_snippet
      let body += [line]
    endif
  endfor
  return snippets
endfunction

function! s:load_global_snippets() abort
  let filename = expand('$VIMHOME/snippets/all.snippets')
  if filereadable(filename)
    for snippet in s:parse_snippet_file(filename)
      call s:add_snippet('s', snippet)
    endfor
  endif
endfunction

function! s:load_filetype_snippets() abort
  let b:snippets = get(b:, 'snippets', {})
  let l:ft = &ft =~? 'javascript\|typescript' ? 'javascript' : &ft
  let filename = expand(printf('$VIMHOME/snippets/%s.snippets', l:ft))
  if filereadable(filename)
    for snippet in s:parse_snippet_file(filename)
      call s:add_snippet('b', snippet)
    endfor
  endif
endfunction

function! s:trigger() abort
  let word = matchstr(getline('.'), '\w*\%'.(col('.') + 1).'c')
  let all = s:available_snippets()
  if has_key(all, word)
    let snippet = all[word]
  else
    call z#echowarn(printf('No snippet for "%s" found', word))
    return
  endif
  let start_pos = getpos('.')
  " can't do ciw here because there may be chars in front of the cursor, so
  " backspace as many times as necessary to delete the trigger word
  execute 'normal! a' repeat("\<BS>", len(word) + 1) "\<Esc>"
  if snippet.expr
    execute printf("normal! \"=%s\<Enter>gP", snippet.rhs)
  else
    let save_s = @s
    let @s = snippet.rhs
    normal! "sgP
    let @s = save_s
  endif
  let num_lines = line('.') - start_pos[1]
  if num_lines > 0
    " if this snippet is multi-line, format it to fix indentation. =k moves the
    " cursor, so save its position and restore it after the formatting
    let new_pos = getpos('.')
    execute printf('normal! %s=k', num_lines)
    call setpos('.', new_pos)
  endif
  if snippet.rhs =~ s:marker
    " if there's a cursor marker, put the cursor where the trigger word started
    " and then search forward from there
    call setpos('.', start_pos)
    call s:jump(0)
  else
    startinsert
  endif
endfunction

autocmd VimEnter * call <SID>load_global_snippets()
autocmd FileType * call <SID>load_filetype_snippets()

inoremap <C-]> <Esc>:call <SID>trigger()<Enter>
inoremap <C-f> <C-o>:call <SID>jump(1)<Enter>

command! -nargs=* Snippet call s:snippet(<f-args>)
