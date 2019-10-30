let s:save_file = expand('$XDG_DATA_HOME/nvim/scratch.txt')
let s:bufname = '__Scratch__'

function! s:height() abort
  return min([10, &lines / 3])
endfunction

function! s:read() abort
  let pos = getcurpos()
  execute '%delete _'
  call setline(1, readfile(s:save_file))
  call setpos('.', pos)
  let b:ftime = localtime()
endfunction

function! s:write() abort
  call writefile(getline(1, '$'), s:save_file)
  let b:ftime = localtime()
endfunction

function! s:new_buffer() abort
  execute 'topleft' s:height() 'new' s:bufname
  setlocal filetype=scratch bufhidden=hide nobuflisted buftype=nofile noswapfile
  setlocal textwidth=0 winfixheight winfixwidth statusline=%F%=%c%V\ :\ %l/%L
  setlocal formatoptions-=o formatoptions-=r
  Wrap
  nnoremap <buffer> q :close<CR>
  nnoremap <buffer> R :call <SID>read()<CR>
  nnoremap <buffer> <leader>s :wincmd p<CR>
  augroup scratch
    autocmd!
    autocmd WinLeave <buffer> call s:close_window()
  augroup END
endfunction

function! s:close_window() abort
  if !filereadable(s:save_file) || get(b:, 'ftime') >= getftime(s:save_file)
    call s:write()
    execute bufwinnr(s:bufname) 'close'
  elseif filereadable(s:save_file) && get(b:, 'ftime') < getftime(s:save_file)
    if confirm('Scratch buffer changed since loading. Write anyway?',
          \ "&Yes\n&No", 2) == 1
      call s:write()
      execute bufwinnr(s:bufname) 'close'
    endif
  endif
endfunction

function! s:open_buffer() abort
  let bnum = bufnr(s:bufname)
  if bnum == -1
    call s:new_buffer()
    if filereadable(s:save_file)
      call s:read()
    endif
  else
    let wnum = bufwinnr(bnum)
    if wnum == -1
      execute 'topleft' s:height() 'split +buffer'.bnum
    else
      execute bnum 'wincmd w'
    endif
    if filereadable(s:save_file) && getftime(s:save_file) > get(b:, 'ftime')
      call s:read()
    endif
  endif
endfunction

function! s:selection() abort
  let [contents, type] = [getreg('"'), getregtype('"')]
  normal! y
  call s:open_buffer()
  execute '%delete _'
  put
  normal! ggdd
  call setreg('"', contents, type)
endfunction

command! ScratchBuffer call <SID>scratch()

nnoremap <silent> <leader>s <Cmd>call <SID>open_buffer()<CR>
xnoremap <silent> <leader>s <Cmd>call <SID>selection()<CR>
