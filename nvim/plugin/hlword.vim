highlight! hlWord gui=underline cterm=underline

function! s:windo(cmd) abort
  let w = winnr()
  execute 'windo' a:cmd
  execute w 'wincmd w'
endfunction

function! s:toggle() abort
  let pat = '\<'.expand('<cword>').'\>'
  if z#char_after_cursor() =~ '\s'
        \ || z#any(getmatches(), {m -> m.group == 'hlWord' && m.pattern == pat})
    call s:windo('2match none')
  elseif z#char_after_cursor() =~ '\w'
    call s:windo('2match hlWord /'.pat.'/')
  endif
endfunction

nnoremap <silent> <C-Space> :call <SID>toggle()<CR>
nnoremap <silent> <Space>
      \  :if v:hlsearch
      \\|   execute 'nohlsearch \| call <SID>windo("2match none")'
      \\| else
      \\|   call <SID>toggle()
      \\| endif<CR>
" this ↑ can't be a function because `v:hlsearch` is reset when a function ends
