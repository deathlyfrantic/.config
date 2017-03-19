function! s:go_away_swap(file, swap)
    let l:ftime = getftime(a:file)
    let l:stime = getftime(a:swap)
    if l:ftime < l:stime
        let l:choice =  "o"
        let l:msg = "Swap file for ".a:file." exists; opening read-only."
    else
        let l:choice = "d"
        let l:msg = "Swap file for ".a:file." older than file; deleted."
    endif
    call s:delayed_message(l:msg)
    let v:swapchoice = l:choice
endfunction

function! s:delayed_message(msg)
    augroup swap_delayed_message
        autocmd!
        autocmd BufEnter * echohl WarningMsg
        exec "autocmd BufEnter * echomsg '".a:msg."'"
        autocmd BufEnter * echohl NONE
        autocmd BufEnter * augroup swap_delayed_message
        autocmd BufEnter * autocmd!
        autocmd BufEnter * augroup END
    augroup END
endfunction

augroup swap_command
    autocmd!
    autocmd SwapExists * call s:go_away_swap(expand("<afile>"), v:swapname)
augroup END
