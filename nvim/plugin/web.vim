" information superhighway
nmap gw <Plug>(websearch)
xmap gw <Plug>(websearch)
nnoremap <silent> <Plug>(websearch) :set opfunc=<SID>google_operator<CR>g@
xnoremap <silent> <Plug>(websearch) :<C-u>call <SID>google_operator(visualmode())<CR>

command! -nargs=1 Web call <SID>browser(<f-args>)
command! -nargs=1 Google call <SID>google(<f-args>)

function! s:google_operator(type) abort
  let l:regsave = @@
  let l:selsave = &selection
  let &selection = 'inclusive'

  if a:type =~? 'v'
    silent execute "normal! gvy"
  elseif a:type == 'line'
    silent execute "normal! '[V']y"
  else
    silent execute "normal! `[v`]y"
  endif

  let l:url = @@
  let &selection = selsave
  let @@ = regsave

  call <SID>google(l:url)
endfunction

function! s:google(url)
  if a:url =~? 'http'
    let l:url = a:url
  else
    let l:url = 'https://duckduckgo.com/?q='.a:url
  endif
  call <SID>browser(l:url)
endfunction

function! s:browser(url)
  let l:command = '!xdg-open "'.a:url.'"'
  silent execute l:command
endfunction
