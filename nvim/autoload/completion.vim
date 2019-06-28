function! completion#findstart() abort
  let [curpos, pos] = [getcurpos(), searchpos('\s', 'bn')]
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
    let lines = readfile(expand('$XDG_CONFIG_HOME/mutt/aliases.muttrc'))
    let s:email_aliases = filter(lines, {_, line -> line =~? '^alias'})
  endif
  let emails = sort(filter(deepcopy(s:email_aliases),
        \ {_, alias -> substitute(alias, '^alias', '', '') =~? a:base}))
  return map(emails, {_, alias -> substitute(alias, '^alias \w\+ ', '', '')})
endfunction

function! completion#undouble()
  " stolen from Damian Conway
  " (https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/.vimrc#L1285-L1298)
  let [col, line] = [col('.'), getline('.')]
  call setline('.', substitute(line, '\(\.\?\k\+\)\%'.col.'c\zs\1', '', ''))
endfunction
