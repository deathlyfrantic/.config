let s:keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p']

for i in range(len(s:keys))
  let s:lhs = has('nvim') ? '<M-'.s:keys[i].'>' : ''.s:keys[i]
  execute 'nmap <silent> '.s:lhs.' :call <SID>buffer_switch('.i.')<CR>'
endfor

function! s:buffer_switch(buf_num) abort
  try
    let l:bn = buftabline#user_buffers()[a:buf_num]
    let l:cmd = 'b'.l:bn
    execute l:cmd
  catch
  endtry
endfunction
