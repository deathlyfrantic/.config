" make sure neomake can find include dir
let b:code_dir = expand('~').'/Code/'
let b:file_dir = fnamemodify(expand('%'), ':p:h')
let b:project_dir = split(substitute(b:file_dir, b:code_dir, '', ''), '/')[0]
let b:include_dir = b:code_dir.b:project_dir.'/include/'
let b:neomake_c_clang_args = ['-fsyntax-only', '-Wall', '-Wextra', '-I'.b:include_dir]
let b:neomake_c_enabled_makers = ['clang']
