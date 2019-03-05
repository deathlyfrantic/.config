let s:packages = []
let s:lazy = {'ft': {}, 'on_cmd': {}, 'on_map': {}}
let s:packager_installed = get(s:, 'packager_installed',
      \ isdirectory(expand('$VIMHOME/pack/packager')))

if !s:packager_installed
  execute '!git clone https://github.com/kristijanhusak/vim-packager'
        \ expand('$VIMHOME/pack/packager/opt/vim-packager')
  let s:packager_installed = 1
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

function! s:pkg_ft(ft, pkgs, clear) abort
  let group = 'z-packages-'.a:ft
  if a:clear
    execute 'autocmd!' group
    execute 'augroup!' group
    doautocmd FileType
    return
  endif
  execute 'augroup' group
    for pkg in a:pkgs
      execute 'autocmd FileType' a:ft 'packadd' pkg
    endfor
    execute 'autocmd FileType' a:ft 'call <SID>pkg_ft("'.a:ft.'", [], 1)'
  augroup END
endfunction

function! s:pkg_cmd(cmd, name) abort
  execute 'silent! delcommand' a:cmd
  execute 'packadd' a:name
  execute a:cmd
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
  if get(s:, 'packager_initialized', 0)
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

for [ft, pkgs] in items(s:lazy.ft)
  call s:pkg_ft(ft, pkgs, 0)
endfor

for [cmd, pkg] in items(s:lazy.on_cmd)
  execute 'command! -bar' cmd 'call <SID>pkg_cmd("'.cmd.'", "'.pkg.'")'
endfor

for [map, pkg] in items(s:lazy.on_map)
  execute 'nmap <silent>' map ':call <SID>pkg_map("'.map.'", "'.pkg.'", 0)<CR>'
  execute 'xmap <silent>' map ':call <SID>pkg_map("'.map.'", "'.pkg.'", 1)<CR>'
endfor
