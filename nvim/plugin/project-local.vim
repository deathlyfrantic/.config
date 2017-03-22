function! s:source_local_vimrc()
    " prevent this from breaking fugitive's Gdiff
    if expand('%') =~? 'fugitive://'
        return
    endif

    let l:dir = expand('%:p:h')

    while l:dir != '/'
        let l:vimrc = l:dir . '/' . '.vimrc'

        if filereadable(l:vimrc)
            execute 'source ' . l:vimrc
            break
        endif

        let l:dir = fnamemodify(l:dir, ':h')
    endwhile
endfunction

autocmd BufNewFile,BufReadPost * call <SID>source_local_vimrc()