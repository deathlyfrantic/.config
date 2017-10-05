function! completion#findstart() abort
  let l:curpos = getcurpos()
  let l:pos = searchpos('\s', 'b')
  return (l:pos[0] == l:curpos[1]) ? l:pos[1] : 0
endfunction

function! completion#email(findstart, base) abort
  if a:findstart
    return completion#findstart()
  endif
  let l:aliases = readfile(expand('$XDG_CONFIG_HOME/mutt/aliases.muttrc'))
  let l:emails = filter(l:aliases, 'substitute(v:val, "^alias ", "", "") =~? a:base')
  return sort(map(copy(l:emails), 'substitute(v:val, "^alias \\w\\+ ", "", "")'))
endfunction

function! completion#char_before_cursor() abort
  let l:col = col('.') - 1
  if l:col <= 0
    return ''
  endif
  return getline('.')[l:col - 1]
endfunction

function! completion#check_back_space() abort
  let l:prev_char = completion#char_before_cursor()
  return l:prev_char =~ '^\s*$'
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
  let l:snippets = UltiSnips#SnippetsInCurrentScope()
  let l:keys = filter(sort(keys(l:snippets)), 'substitute(v:val, "^alias ", "", "") =~? a:base')
  return sort(map(copy(l:keys), '{"word": v:val, "menu": l:snippets[v:val]}'))
endfunction
