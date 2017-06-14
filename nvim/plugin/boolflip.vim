function! s:should_cap() abort
    if &ft == 'python'
        return 1
    endif
    return 0
endfunction

function! s:true() abort
    return (<SID>should_cap()) ? 'True' : 'true'
endfunction

function! s:false() abort
    return (<SID>should_cap()) ? 'False' : 'false'
endfunction

function! s:bool_flip() abort
    let l:word = expand('<cWORD>')
    let l:flip = 0
    if l:word =~? 'true'
        let l:flip = <SID>false()
    elseif l:word =~? 'false'
        let l:flip = <SID>true()
    endif
    if type(l:flip) == type('')
        execute 'normal! ciW'.l:flip
    endif
endfunction

command! BoolFlip call <SID>bool_flip()
nnoremap <silent> Q :BoolFlip<CR>
