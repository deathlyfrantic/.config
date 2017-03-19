" " when true, uses <C-N>; when false, uses <C-P>
" let s:pum_fwd = 1
" let s:spell_fts = ['markdown', 'mail', 'text', 'gitcommit']
" let s:spell_syn = ['Comment', 'Todo']

function! s:check_back_space() abort
    let l:col = col('.') - 1
    return !l:col || getline('.')[l:col - 1] =~? '\s'
endfunction

" function! s:ctrl_np(fwd) abort
"     let s:pum_fwd = a:fwd
"     return s:move_dir(s:pum_fwd)
" endfunction

" function! s:move_dir(fwd) abort
"     " dynamically building the key combination _does not work_ for reasons
"     return (a:fwd) ? "\<C-N>" : "\<C-P>"
" endfunction

" function! s:get_word() abort
"     let l:pos = getpos('.')
"     let l:new_pos = deepcopy(l:pos)
"     let l:new_pos[2] -= 1
"     call setpos('.', l:new_pos)
"     let l:word = expand('<cWORD>')
"     call setpos('.', l:pos)
"     return l:word
" endfunction

" function! s:is_file() abort
"     let l:path = s:get_word()
"     if stridx(l:path, '~') > -1
"         let l:path = strpart(l:path, stridx(l:path, '~'))
"     elseif stridx(l:path, '/') > -1
"         let l:path = strpart(l:path, stridx(l:path, '/'))
"     endif
"     let l:path = expand(l:path)
"     let l:base_dir = strpart(l:path, 0, strridx(l:path, '/'))
"     return l:path[0] == '/' || isdirectory(l:path) || isdirectory(l:base_dir)
" endfunction

" function! s:spelling() abort
"     let l:syntax = synIDattr(synID(line('.'), col('.'), 0), 'name')
"     return &spell && (index(s:spell_fts, &filetype) > -1 || index(s:spell_syn, l:syntax))
" endfunction

" function! s:complete(omni) abort
"     if s:is_file()
"         return "\<C-X>\<C-F>"
"     elseif s:spelling()
"         return (a:omni) ? "\<C-X>s" : s:ctrl_np(0)
"     else
"         return (a:omni) ? "\<C-X>\<C-O>" : s:ctrl_np(0)
"     endif
" endfunction

" function! s:tab(fwd) abort
"     if pumvisible()
"         return (a:fwd) ? s:move_dir(s:pum_fwd) : s:move_dir(!s:pum_fwd)
"     elseif !s:check_back_space()
"         return s:complete(!a:fwd)
"     endif
"     return "\<Tab>"
" endfunction

function! s:tab(fwd) abort
    if pumvisible()
        return (a:fwd) ? "\<C-N>" : "\<C-P>"
    elseif !s:check_back_space()
        return "\<C-P>"
    endif
    return "\<Tab>"
endfunction

" inoremap <expr> <silent> <C-N> <SID>ctrl_np(1)
" inoremap <expr> <silent> <C-P> <SID>ctrl_np(0)
inoremap <expr> <silent> <Tab> <SID>tab(1)
inoremap <expr> <silent> <S-Tab> <SID>tab(0)
