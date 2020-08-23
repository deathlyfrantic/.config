setlocal omnifunc=python3complete#Complete

let s:pydoc_window = -1
function! s:pydoc_man(...) abort
  let pydoc = executable('pydoc3') ? 'pydoc3' : 'pydoc'
  let s:pydoc_window = z#popup(systemlist(pydoc .. ' ' .. a:1))
  autocmd CursorMoved * ++once call nvim_win_close(s:pydoc_window, 1)
        \| let s:pydoc_window = -1
endfunction

command! -nargs=1 PydocPreview call <SID>pydoc_man(<f-args>)
setlocal keywordprg=:PydocPreview

" highlight docstrings as comments
function! s:docstring_highlight() abort
  syntax region pythonDocstring start=+^\s*[uU]\?[rR]\?\%("""\|'''\)+
        \ end=+\%("""\|'''\)+ keepend excludenl
        \ contains=pythonEscape,@Spell,pythonDoctest,pythonDocTest2,pythonSpaceError
  highlight default link pythonDocstring pythonComment
endfunction

autocmd Syntax <buffer> call <SID>docstring_highlight()
