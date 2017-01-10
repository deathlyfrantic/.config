" when true, uses <C-N>; when false, uses <C-P>
let s:pum_fwd = 1

function! s:check_back_space() abort
  let l:col = col('.') - 1
  return !l:col || getline('.')[l:col - 1] =~? '\s'
endfunction

function! s:ctrl_np(fwd) abort
  let s:pum_fwd = a:fwd
  return s:move_dir(s:pum_fwd)
endfunction

function! s:move_dir(fwd) abort
  " dynamically building the key combination _does not work_ for reasons
  return (a:fwd) ? "\<C-N>" : "\<C-P>"
endfunction

function! s:tab(fwd) abort
  if pumvisible()
    return (a:fwd) ? s:move_dir(s:pum_fwd) : s:move_dir(!s:pum_fwd)
  elseif !s:check_back_space()
    return s:ctrl_np(0)
  endif
  return "\<Tab>"
endfunction

inoremap <expr> <silent> <C-N> <SID>ctrl_np(1)
inoremap <expr> <silent> <C-P> <SID>ctrl_np(0)
inoremap <expr> <silent> <Tab> <SID>tab(1)
inoremap <expr> <silent> <S-Tab> <SID>tab(0)
