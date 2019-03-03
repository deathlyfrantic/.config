let s:search_url = 'https://duckduckgo.com/?q=%s'

function! s:operator(type) abort
  let regsave = @@
  let selsave = &selection
  let &selection = 'inclusive'
  if a:type =~? 'v\|line\|'
    silent execute 'normal! y'
  else
    silent execute 'normal! `[v`]y'
  endif
  let url = @@
  let &selection = selsave
  let @@ = regsave
  call <SID>search(url)
endfunction

function! s:search(url)
  let url = a:url =~? 'http' ? a:url : printf(s:search_url, a:url)
  call <SID>browser(url)
endfunction

function! s:browser(url)
  let open = has('mac') ? 'open -g' : 'xdg-open'
  silent execute '!' open shellescape(a:url, 1)
endfunction

" Browse alias is for Fugitive's Gbrowse
command! -nargs=1 Browse Web <args>
command! -nargs=1 Web call <SID>browser(<f-args>)
command! -nargs=1 Search call <SID>search(<f-args>)

nnoremap <silent> <Plug>(websearch) :set opfunc=<SID>operator<CR>g@
xnoremap <silent> <Plug>(websearch) <Cmd>call <SID>operator(mode())<CR>
nmap gw <Plug>(websearch)
xmap gw <Plug>(websearch)
