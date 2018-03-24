function! completion#findstart() abort
  let curpos = getcurpos()
  let pos = searchpos('\s', 'b')
  return (pos[0] == curpos[1]) ? pos[1] : 0
endfunction

function! completion#email(findstart, base) abort
  if a:findstart
    return completion#findstart()
  endif
  let aliases = readfile(expand('$XDG_CONFIG_HOME/mutt/aliases.muttrc'))
  let emails = sort(filter(aliases,
    \ {i, v -> substitute(v, '^alias', '', '') =~? a:base}))
  return map(emails, {i, v -> substitute(v, '^alias \w\+ ', '', '')})
endfunction

function! completion#char_before_cursor() abort
  let col = col('.') - 1
  if col <= 0
    return ''
  endif
  return getline('.')[col - 1]
endfunction

function! completion#check_back_space() abort
  return completion#char_before_cursor() =~ '^\s*$'
endfunction

function! completion#tab(fwd) abort
  if pumvisible()
    return (a:fwd) ? "\<C-N>" : "\<C-P>"
  elseif !completion#check_back_space()
    return "\<C-P>"
  endif
  return "\<Tab>"
endfunction

function! completion#snippet(findstart, base) abort
  if a:findstart
    return completion#findstart()
  endif
  let snippets = UltiSnips#SnippetsInCurrentScope()
  let keys = filter(sort(keys(snippets)), {i, v -> v =~? a:base})
  return map(keys, {i, v -> {'word': v, 'menu': snippets[v]}})
endfunction
