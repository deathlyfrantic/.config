function! completion#findstart() abort
  " must call getcurpos() first here; searchpos() moves the cursor,
  " so calling getcurpos() after searchpos() returns the wrong position
  let [curpos, pos] = [getcurpos(), searchpos('\s', 'b')]
  return pos[0] == curpos[1] ? pos[1] : 0
endfunction

function! completion#char_before_cursor() abort
  let col = col('.') - 2
  return col < 0 ? '' : getline('.')[col]
endfunction

function! completion#check_back_space() abort
  return completion#char_before_cursor() =~ '^\s*$'
endfunction

function! completion#tab(fwd) abort
  if pumvisible()
    return a:fwd ? "\<C-N>" : "\<C-P>"
  elseif !completion#check_back_space()
    return "\<C-P>"
  endif
  return "\<Tab>"
endfunction

function! completion#email(findstart, base) abort
  if a:findstart
    return completion#findstart()
  endif
  if !exists('s:email_aliases')
    let files = globpath('$XDG_CONFIG_HOME/mutt', '*', 0, 1)
    let lines = z#flatten(map(files, {_, file -> readfile(file)}))
    let s:email_aliases = filter(lines, {_, line -> line =~? '^alias'})
  endif
  let emails = sort(filter(deepcopy(s:email_aliases),
    \ {_, alias -> substitute(alias, '^alias', '', '') =~? a:base}))
  return map(emails, {_, alias -> substitute(alias, '^alias \w\+ ', '', '')})
endfunction

function! completion#snippet(findstart, base) abort
  if a:findstart
    return completion#findstart()
  endif
  if !exists('*UltiSnips#SnippetsInCurrentScope')
    return []
  endif
  let snippets = UltiSnips#SnippetsInCurrentScope()
  let keys = filter(sort(keys(snippets)), {_, key -> key =~? a:base})
  return map(keys, {_, key -> {'word': key, 'menu': snippets[key]}})
endfunction
