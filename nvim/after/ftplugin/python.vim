setlocal omnifunc=python3complete#Complete

function! s:pydoc_man(...) abort
  call z#preview(systemlist(printf('pydoc3 %s', a:1)))
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

packadd neoformat
let b:neoformat_python_black = get(b:, 'neoformat_python_black',
      \ extend(neoformat#formatters#python#black(), {'args': ['-l 80', '-']}))
