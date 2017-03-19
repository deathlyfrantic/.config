nmap <silent> <M-1> :call <SID>buffer_switch(0)<CR>
nmap <silent> <M-2> :call <SID>buffer_switch(1)<CR>
nmap <silent> <M-3> :call <SID>buffer_switch(2)<CR>
nmap <silent> <M-4> :call <SID>buffer_switch(3)<CR>
nmap <silent> <M-5> :call <SID>buffer_switch(4)<CR>
nmap <silent> <M-6> :call <SID>buffer_switch(5)<CR>
nmap <silent> <M-7> :call <SID>buffer_switch(6)<CR>
nmap <silent> <M-8> :call <SID>buffer_switch(7)<CR>
nmap <silent> <M-9> :call <SID>buffer_switch(8)<CR>
nmap <silent> <M-0> :call <SID>buffer_switch(9)<CR>
nmap <silent> <M-q> :call <SID>buffer_switch(10)<CR>
nmap <silent> <M-w> :call <SID>buffer_switch(11)<CR>
nmap <silent> <M-e> :call <SID>buffer_switch(12)<CR>
nmap <silent> <M-r> :call <SID>buffer_switch(13)<CR>
nmap <silent> <M-t> :call <SID>buffer_switch(14)<CR>
nmap <silent> <M-y> :call <SID>buffer_switch(15)<CR>
nmap <silent> <M-u> :call <SID>buffer_switch(16)<CR>
nmap <silent> <M-i> :call <SID>buffer_switch(17)<CR>
nmap <silent> <M-o> :call <SID>buffer_switch(18)<CR>
nmap <silent> <M-p> :call <SID>buffer_switch(19)<CR>

function! s:buffer_switch(buf_num)
    try
        let l:bn = buftabline#user_buffers()[a:buf_num]
        let l:cmd = 'b'.l:bn
        execute l:cmd
    catch
    endtry
endfunction
