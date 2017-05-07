function! s:check_back_space() abort
    let l:col = col('.') - 1
    return !l:col || getline('.')[l:col - 1] =~? '\s'
endfunction

function! s:tab(fwd) abort
    if pumvisible()
        return (a:fwd) ? "\<C-N>" : "\<C-P>"
    elseif !s:check_back_space()
        return "\<C-P>"
    endif
    return "\<Tab>"
endfunction

inoremap <expr> <silent> <Tab> <SID>tab(1)
inoremap <expr> <silent> <S-Tab> <SID>tab(0)
