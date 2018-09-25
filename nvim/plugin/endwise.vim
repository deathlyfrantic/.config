" Location:     plugin/endwise.vim
" Author:       Tim Pope <http://tpo.pe/>
" Version:      1.2
" License:      Same as Vim itself.  See :help license
" GetLatestVimScripts: 2386 1 :AutoInstall: endwise.vim

if exists("g:loaded_endwise") || &cp
  finish
endif
let g:loaded_endwise = 1

augroup endwise " {{{1
  autocmd!
  autocmd FileType lua let b:endwise = {
    \ 'addition': 'end',
    \ 'words': 'function,do,then',
    \ 'pattern': '^\s*\zs\%(\%(local\s\+\)\=function\)\>\%(.*\<end\>\)\@!\|\<\%(then\|do\)\ze\s*$',
    \ 'syngroups': 'luaFunction,luaStatement,luaCond'}
  autocmd FileType ruby let b:endwise = {
    \ 'addition': 'end',
    \ 'words': 'module,class,def,if,unless,case,while,until,begin,do',
    \ 'pattern': '^\(.*=\)\?\s*\%(private\s\+\|protected\s\+\|public\s\+\|module_function\s\+\)*\zs\%(module\|class\|def\|if\|unless\|case\|while\|until\|for\|\|begin\)\>\%(.*[^.:@$]\<end\>\)\@!\|\<do\ze\%(\s*|.*|\)\=\s*$',
    \ 'syngroups': 'rubyModule,rubyClass,rubyDefine,rubyControl,rubyConditional,rubyRepeat'}
  autocmd FileType sh,zsh let b:endwise = {
    \ 'addition': '\=submatch(0)=="then" ? "fi" : submatch(0)=="case" ? "esac" : "done"',
    \ 'words': 'then,case,do',
    \ 'pattern': '\%(^\s*\zscase\>\ze\|\zs\<\%(do\|then\)\ze\s*$\)',
    \ 'syngroups': 'shConditional,shLoop,shIf,shFor,shRepeat,shCaseEsac,zshConditional,zshRepeat,zshDelimiter'}
  autocmd FileType vim let b:endwise = {
    \ 'addition': '\=submatch(0)=~"aug\\%[roup]" ? submatch(0) . " END" : "end" . submatch(0)',
    \ 'words': 'fu\%[nction],wh\%[ile],if,for,try,aug\%[roup]\%(\s\+\cEND\)\@!',
    \ 'end_pattern': '\%(end\%(fu\%[nction]\|wh\%[hile]\|if\|for\|try\)\)\|aug\%[roup]\%(\s\+\cEND\)',
    \ 'syngroups': 'vimFuncKey,vimNotFunc,vimCommand,vimAugroupKey,vimAugroup,vimAugroupError'}
  autocmd FileType c,cpp,xdefaults,haskell let b:endwise = {
    \ 'addition': '#endif',
    \ 'words': 'if,ifdef,ifndef',
    \ 'pattern': '^\s*#\%(if\|ifdef\|ifndef\)\>',
    \ 'syngroups': 'cPreCondit,cPreConditMatch,cCppInWrapper,xdefaultsPreProc'}
  autocmd FileType objc let b:endwise = {
    \ 'addition': '@end',
    \ 'words': 'interface,implementation',
    \ 'pattern': '^\s*@\%(interface\|implementation\)\>',
    \ 'syngroups': 'objcObjDef'}
  autocmd FileType htmldjango let b:endwise = {
    \ 'addition': '{% end& %}',
    \ 'words': 'autoescape,block,blocktrans,cache,comment,filter,for,if,ifchanged,ifequal,ifnotequal,language,spaceless,verbatim,with',
    \ 'syngroups': 'djangoTagBlock,djangoStatement'}
  autocmd FileType htmljinja,jinja.html let b:endwise = {
    \ 'addition': '{% end& %}',
    \ 'words': 'autoescape,block,cache,call,filter,for,if,macro,raw,set,trans,with',
    \ 'syngroups': 'jinjaTagBlock,jinjaStatement'}
  autocmd FileType snippets let b:endwise = {
    \ 'addition': 'endsnippet',
    \ 'words': 'snippet',
    \ 'syngroups': 'snipSnippet,snipSnippetHeader,snipSnippetHeaderKeyword'}
  autocmd FileType rust let b:endwise = {
    \ 'addition': '}',
    \ 'words': 'fn,impl,struct,enum',
    \ 'pattern': '^\s*\%(\%[pub ]fn\|impl\|struct\|enum\|mod\).*{$',
    \ 'syngroups': 'rustKeyword,rustFoldBraces,rustStructure,dummy'}
augroup END " }}}1

function! s:teardownMappings()
  inoremap <buffer> <C-X><CR> <C-X><CR>
  inoremap <buffer> <CR> <CR>
endfunction

" Functions {{{1

function! EndwiseDiscretionary()
  return <SID>crend(0)
endfunction

function! EndwiseAlways()
  return <SID>crend(1)
endfunction

" }}}1

" Maps {{{1

if maparg("<Plug>DiscretionaryEnd") == ""
  inoremap <silent> <SID>DiscretionaryEnd <C-R>=<SID>crend(0)<CR>
  inoremap <silent> <SID>AlwaysEnd        <C-R>=<SID>crend(1)<CR>
  imap    <script> <Plug>DiscretionaryEnd <SID>DiscretionaryEnd
  imap    <script> <Plug>AlwaysEnd        <SID>AlwaysEnd
endif

if !exists('g:endwise_no_mappings')
  if maparg('<CR>', 'i') =~# '<C-R>=.*crend(.)<CR>\|<\%(Plug\|SNR\|SID\)>.*End'
    " Already mapped
  elseif maparg('<CR>', 'i') =~ '<CR>'
    exe "imap <script> <C-X><CR> ".maparg('<CR>', 'i')."<SID>AlwaysEnd"
    exe "imap <silent> <script> <CR> ".maparg('<CR>', 'i')."<SID>DiscretionaryEnd"
  elseif maparg('<CR>', 'i') =~ '<Plug>\w\+CR'
    exe "imap <C-X><CR> ".maparg('<CR>', 'i')."<Plug>AlwaysEnd"
    exe "imap <silent> <CR> ".maparg('<CR>', 'i')."<Plug>DiscretionaryEnd"
  else
    imap <script> <C-X><CR> <CR><SID>AlwaysEnd
    imap <CR> <CR><Plug>DiscretionaryEnd
  endif
  autocmd endwise CmdwinEnter * call s:teardownMappings()
endif

" }}}1

" Code {{{1

function! s:mysearchpair(beginpat, endpat, synidpat)
  let s:lastline = line('.')
  call s:synid()
  let line = searchpair(a:beginpat, '', a:endpat, 'Wn', '<SID>synid() !~# "^'.substitute(a:synidpat, '\\', '\\\\', 'g').'$"', line('.') + 50)
  return line
endfunction

function! s:crend(always)
  let n = ""
  if !exists("b:endwise")
    return n
  endif
  let synids = join(map(split(b:endwise.syngroups, ','), 'hlID(v:val)'), ',')
  let wordchoice = '\%('.substitute(b:endwise.words, ',', '\\|', 'g').'\)'
  if has_key(b:endwise, "pattern")
    let beginpat = substitute(b:endwise.pattern, '&', substitute(wordchoice, '\\', '\\&', 'g'), 'g')
  else
    let beginpat = '\<'.wordchoice.'\>'
  endif
  let lnum = line('.') - 1
  let space = matchstr(getline(lnum), '^\s*')
  let col = match(getline(lnum), beginpat) + 1
  let word = matchstr(getline(lnum), beginpat)
  let endword = substitute(word, '.*', b:endwise.addition, '')
  let y = n.endword."\<C-O>O"
  if has_key(b:endwise, "end_pattern")
    let endpat = '\w\@<!'.substitute(word, '.*', substitute(b:endwise.end_pattern, '\\', '\\\\', 'g'), '').'\w\@!'
  elseif b:endwise.addition[0:1] ==# '\='
    let endpat = '\w\@<!'.endword.'\w\@!'
  else
    let endpat = '\w\@<!'.substitute('\w\+', '.*', b:endwise.addition, '').'\w\@!'
  endif
  let synidpat = '\%('.substitute(synids, ',', '\\|', 'g').'\)'
  if a:always
    return y
  elseif col <= 0 || synID(lnum, col, 1) !~ '^'.synidpat.'$'
    return n
  elseif getline('.') !~ '^\s*#\=$'
    return n
  endif
  if b:endwise.addition =~ '}\%[;]'
    let line = s:mysearchpair('{', '}', synidpat)
  else
    let line = s:mysearchpair(beginpat, endpat, synidpat)
  endif
  " even is false if no end was found, or if the end found was less
  " indented than the current line
  let even = strlen(matchstr(getline(line), '^\s*')) >= strlen(space)
  if line == 0
    let even = 0
  endif
  if !even && line == line('.') + 1
    return y
  endif
  if even
    return n
  endif
  return y
endfunction

function! s:synid()
  " Checking this helps to force things to stay in sync
  while s:lastline < line('.')
    let s = synID(s:lastline, indent(s:lastline) + 1, 1)
    let s:lastline = nextnonblank(s:lastline + 1)
  endwhile
  let s = synID(line('.'), col('.'), 1)
  let s:lastline = line('.')
  return s
endfunction

" }}}1

" vim:set sw=2 sts=2:
