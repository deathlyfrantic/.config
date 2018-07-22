" information superhighway
nmap gw <Plug>(websearch)
xmap gw <Plug>(websearch)
nnoremap <silent> <Plug>(websearch) :set opfunc=<SID>search_operator<CR>g@
xnoremap <silent> <Plug>(websearch) :<C-u>call <SID>search_operator(visualmode())<CR>

" Browse alias is for Fugitive's Gbrowse
command! -nargs=1 Browse Web <args>
command! -nargs=1 Web call <SID>browser(<f-args>)
command! -nargs=1 Search call <SID>search(<f-args>)

function! s:search_operator(type) abort
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

  call <SID>search(l:url)
endfunction

function! s:search(url)
  let l:url = a:url =~? 'http' ? a:url : 'https://duckduckgo.com/?q='.a:url
  call <SID>browser(l:url)
endfunction

function! s:browser(url)
  let l:open = has('mac') ? 'open -g' : 'xdg-open'
  silent execute printf('!%s %s', l:open, shellescape(a:url, 1))
endfunction
