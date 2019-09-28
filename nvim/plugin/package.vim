let s:packages = []
let s:lazy = {'ft': {}, 'on_cmd': {}, 'on_map': {}}

if !isdirectory(expand('$VIMHOME/pack/packager'))
  execute '!git clone https://github.com/kristijanhusak/vim-packager'
        \ expand('$VIMHOME/pack/packager/opt/vim-packager')
  autocmd VimEnter * ++once PackInstall
endif

function! s:add_package(bang, path, ...) abort
  if a:bang == '!'
    unlet! s:packager_initialized
  endif
  let opts = a:0 ? a:1 : {}
  let name = fnamemodify(a:path, ':t')
  if has_key(opts, 'for')
    let opts.type = 'opt'
    for ft in z#to_list(opts.for)
      if !has_key(s:lazy.ft, ft)
        let s:lazy.ft[ft] = []
      endif
      let s:lazy.ft[ft] += [name]
    endfor
  endif
  if has_key(opts, 'on')
    let opts.type = 'opt'
    for on in z#to_list(opts.on)
      let map_list = on =~? '^<Plug>' ? s:lazy.on_map : s:lazy.on_cmd
      let map_list[on] = name
    endfor
  endif
  let s:packages += [[a:path, opts]]
endfunction

function! s:pkg_cmd(cmd, name, bang, args) abort
  execute 'silent! delcommand' a:cmd
  execute 'packadd' a:name
  execute a:cmd.a:bang a:args
endfunction

function! s:pkg_map(map, name, visual) abort
  execute 'silent! unmap' a:map
  execute 'packadd' a:name
  if a:visual
    call feedkeys('gv', 'n')
  endif
  call feedkeys(substitute(a:map, '^<Plug>', "\<Plug>", ''))
endfunction

function! s:packager_init() abort
  if get(s:, 'packager_initialized')
    return
  endif
  let s:packager_initialized = 1
  packadd vim-packager
  call packager#init()
  for [name, opts] in s:packages
    call packager#{isdirectory(expand(name)) ? 'local' : 'add'}(name, opts)
  endfor
endfunction

command! -bang -nargs=+ Package call <SID>add_package(<q-bang>, <args>)
command! PackClean call <SID>packager_init() | call packager#clean()
command! PackInstall call <SID>packager_init() | call packager#install()
command! PackStatus call <SID>packager_init() | call packager#status()
command! PackUpdate call <SID>packager_init() | call packager#update()

source $VIMHOME/packages.vim

augroup package-filetypes
  autocmd!
  for [ft, pkgs] in items(s:lazy.ft)
    for pkg in pkgs
      execute 'autocmd FileType' ft '++once packadd' pkg
    endfor
    execute 'autocmd FileType' ft '++once ++nested doautocmd FileType'
  endfor
augroup END

for [cmd, pkg] in items(s:lazy.on_cmd)
  execute 'command! -bang -bar -nargs=*' cmd
        \ 'call <SID>pkg_cmd("'.cmd.'", "'.pkg.'", <q-bang>, <q-args>)'
endfor

for [map, pkg] in items(s:lazy.on_map)
  execute 'nmap <silent>' map ':call <SID>pkg_map("'.map.'", "'.pkg.'", 0)<CR>'
  execute 'xmap <silent>' map ':call <SID>pkg_map("'.map.'", "'.pkg.'", 1)<CR>'
endfor
